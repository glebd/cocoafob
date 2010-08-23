/* Copyright (c) 2007 Samuel Tesla
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "encoder.h"

size_t
base32_encoder_last_quintent (const size_t bytes)
{
  int quintets = bytes * 8 / 5;
  int remainder = bytes % 5;
  return remainder == 0 ? quintets : quintets + 1;
}

size_t
base32_encoder_output_padding_size (const size_t bytes)
{
  unsigned remainder = bytes % 5;
  return remainder == 0 ? 0 : (5 - remainder) * 8 / 5;
}

size_t
base32_encoder_buffer_size (const size_t bytes)
{
  return base32_encoder_last_quintent (bytes) +
    base32_encoder_output_padding_size (bytes);
}

static unsigned
base32_encoder_encode_bits (int position, const uint8_t *buffer)
{
  unsigned offset = position / 8 * 5;
  switch (position % 8)
    {
    case 0:
      return
        ((buffer[offset] & 0xF8) >> 3);

    case 1:
      return
        ((buffer[offset] & 0x07) << 2) +
        ((buffer[offset + 1] & 0xC0) >> 6);

    case 2:
      return
        ((buffer[offset + 1] & 0x3E) >> 1);

    case 3:
      return
        ((buffer[offset + 1] & 0x01) << 4) +
        ((buffer[offset + 2] & 0xF0) >> 4);

    case 4:
      return
        ((buffer[offset + 2] & 0x0F) << 1) +
        ((buffer[offset + 3] & 0x80) >> 7);

    case 5:
      return
        ((buffer[offset + 3] & 0x7C) >> 2);

    case 6:
      return
        ((buffer[offset + 3] & 0x03) << 3) +
        ((buffer[offset + 4] & 0xE0) >> 5);

    case 7:
      return
        buffer[offset + 4] & 0x1F;

    default:
      return 0;
    }
}

static inline uint8_t
base32_encoder_encode_at_position (unsigned position, const uint8_t *buffer)
{
  const char *table = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
  unsigned index = base32_encoder_encode_bits (position, buffer);
  return table[index];
}

void
base32_encode (uint8_t *output, const size_t outputLength,
               const uint8_t *input, const size_t inputLength)
{
  unsigned i;
  unsigned quintets = base32_encoder_last_quintent(inputLength);
  for (i = 0; i < quintets; i++)
    output[i] = base32_encoder_encode_at_position (i, input);
  for (i = quintets; i < outputLength; i++)
    output[i] = '=';
}
