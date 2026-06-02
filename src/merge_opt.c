void merge_frames_opt(int h, int w, unsigned char frame1[][w][3],
                      unsigned char frame2[][w][3],
                      unsigned char frame_out[][w][3]) {

  int x, y;
  for (y = 0; y < h; ++y)
    for (x = 0; x < w; ++x) {
      // merge each color component in every pixel
      if (frame1[y][x][0] + frame2[y][x][0] > 255)
        frame_out[y][x][0] = 255;
      else
        frame_out[y][x][0] = frame1[y][x][0] + frame2[y][x][0]; // red

      if (frame1[y][x][1] + frame2[y][x][1] > 255)
        frame_out[y][x][1] = 255;
      else
        frame_out[y][x][1] = frame1[y][x][1] + frame2[y][x][1]; // green

      if (frame1[y][x][2] + frame2[y][x][2] > 255)
        frame_out[y][x][2] = 255;
      else
        frame_out[y][x][2] = frame1[y][x][2] + frame2[y][x][2]; // blue
    }
};