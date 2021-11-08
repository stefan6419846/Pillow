/*
 * The Python Imaging Library
 *
 * encoder for DXT1-compressed data
 *
 * Format documentation:
 *   https://web.archive.org/web/20170802060935/http://oss.sgi.com/projects/ogl-sample/registry/EXT/texture_compression_s3tc.txt
 *
 */

#include "Imaging.h"

#include "Bcn.h"

static rgba
decode_565(UINT16 x) {
    rgba c;
    int r, g, b;
    r = (x & 0xf800) >> 8;
    r |= r >> 5;
    c.r = r;
    g = (x & 0x7e0) >> 3;
    g |= g >> 6;
    c.g = g;
    b = (x & 0x1f) << 3;
    b |= b >> 5;
    c.b = b;
    c.a = 0xff;
    return c;
}

typedef struct {
    UINT8 color[3];
} rgb;

static UINT16
encode_565(rgb item) {
    UINT8 r, g, b;
    r = item.color[0] >> (8 - 5);
    g = item.color[1] >> (8 - 6);
    b = item.color[2] >> (8 - 5);
    return (r << (5 + 6)) | (g << 5) | b;
}

int
ImagingBcnEncode(Imaging im, ImagingCodecState state, UINT8 *buf, int bytes) {
    UINT8 *dst = buf;

    for (;;) {
        int i, j, k, three_color_block = 0;
        UINT16 cmin, cmax;
        rgb block[16], cmin_rgb, cmax_rgb, *current_rgb;

        for (i = 0; i < 4; i++) {
            for (j = 0; j < 4; j++) {
                UINT16 c;
                int x = state->x + i * im->pixelsize;
                int y = state->y + j;
                if (x >= state->xsize * im->pixelsize || y >= state->ysize) {
                    continue;
                }

                current_rgb = &block[i + j * 4];
                for (k = 0; k < 3; k++) {
                  current_rgb->color[k] = (UINT8)im->image[y][x+k];
                }

                c = encode_565(*current_rgb);
                if ((i == 0 && j == 0) || c < cmin) {
                  cmin = c;
                }
                if ((i == 0 && j == 0) || c > cmax) {
                  cmax = c;
                }
            }
        }
        rgba back = decode_565(cmin);
        cmin_rgb.color[0] = back.r;
        cmin_rgb.color[1] = back.g;
        cmin_rgb.color[2] = back.b;
        back = decode_565(cmax);
        cmax_rgb.color[0] = back.r;
        cmax_rgb.color[1] = back.g;
        cmax_rgb.color[2] = back.b;
        if (cmin == cmax) {
          UINT8 r = cmax_rgb.color[0];
          UINT8 g = cmax_rgb.color[1];
          UINT8 b = cmax_rgb.color[2];
          int halves = 0;
          int thirds = 0;
          int posr = 0;
          int negr = 0;
          int posg = 0;
          int negg = 0;
          int posb = 0;
          int negb = 0;
          for (i = 0; i < 16; i++) {
              for (j = 0; j < 3; j++) {
                  int diff = block[i].color[j] - cmin_rgb.color[j];
                  if (diff == (j == 1 ? 2 : 4)) {
                      halves += 1;
                  } else if (diff == (j == 1 ? 1 : 3) || diff == (j == 1 ? 3 : 5)) {
                      thirds += 1;
                  }
                  if (j == 0) {
                    if (diff > 0) {
                      posr += 1;
                    } else if (diff < 0) {
                      negr += 1;
                    }
                  } else if (j == 1) {
                    if (diff > 0) {
                      posg += 1;
                    } else if (diff < 0) {
                      negg += 1;
                    }
                  } else {
                    if (diff > 0) {
                      posb += 1;
                    } else if (diff < 0) {
                      negb += 1;
                    }
                  }
              }
          }
          three_color_block = halves > thirds ? 1 : 0;
          if (posr > negr) {
              cmax_rgb.color[0] += 8;
          } else if (posr < negr) {
              cmin_rgb.color[0] -= 8;
          }
          if (posg > negg) {
              cmax_rgb.color[1] += 4;
          } else if (posg < negg) {
              cmin_rgb.color[1] -= 4;
          }
          if (posb > negb) {
              cmax_rgb.color[2] += 8;
          } else if (posb < negb) {
              cmin_rgb.color[2] -= 8;
          }
          cmin = encode_565(cmin_rgb);
          cmax = encode_565(cmax_rgb);
        }
        if (three_color_block == 1) {
          *dst++ = cmin;
          *dst++ = cmin >> 8;
          *dst++ = cmax;
          *dst++ = cmax >> 8;
          for (i = 0; i < 4; i++) {
            UINT8 m = 0;
            for (j = 3; j > -1; j--) {
              current_rgb = &block[i * 4 + j];

              float distance = 0;
              int total = 0;
              for (k = 0; k < 3; k++) {
                float denom = (float)abs(cmax_rgb.color[k] - cmin_rgb.color[k]);
                if (denom != 0) {
                  distance += abs(current_rgb->color[k] - cmin_rgb.color[k]) / denom;
                  total += 1;
                }
              }
              if (total != 0) {
                distance *= (6 / total);
              }
              if (distance < 1.5) {
                m |= 1 << (j * 2); // 01 cmin
              } else if (distance < 4.5) {
                m |= 2 << (j * 2); // 10 2 cmax 1 cmin
              } else {
                // 00 cmax
              }
            }
            *dst++ = m;
          }
        } else {
          *dst++ = cmax;
          *dst++ = cmax >> 8;
          *dst++ = cmin;
          *dst++ = cmin >> 8;
          for (i = 0; i < 4; i++) {
            UINT8 m = 0;
            for (j = 3; j > -1; j--) {
              current_rgb = &block[i * 4 + j];

              float distance = 0;
              int total = 0;
              for (k = 0; k < 3; k++) {
                float denom = (float)abs(cmax_rgb.color[k] - cmin_rgb.color[k]);
                if (denom != 0) {
                  distance += abs(current_rgb->color[k] - cmin_rgb.color[k]) / denom;
                  total += 1;
                }
              }
              if (total != 0) {
                distance *= (6 / total);
              }
              if (distance < 1) {
                m |= 1 << (j * 2); // 01 cmin
              } else if (distance < 3) {
                m |= 3 << (j * 2); // 11 1 cmax 2 cmin
              } else if (distance < 5) {
                m |= 2 << (j * 2); // 10 2 cmax 1 cmin
              } else {
                // 00 cmax
              }
            }
            *dst++ = m;
          }
        }

        state->x += im->pixelsize * 4;

        if (state->x >= state->xsize * im->pixelsize) {
            state->x = 0;
            state->y += 4;
            if (state->y >= state->ysize) {
                state->errcode = IMAGING_CODEC_END;
                break;
            }
        }
    }

    return dst - buf;
}
