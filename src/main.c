#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
#include <direct.h>
#include <intrin.h>
#include <malloc.h>
#include <windows.h>

#define popen _popen
#define pclose _pclose

#else
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#endif

#define W 1796
#define H 738
#define N_BYTES (W * H * 3)

#ifdef _WIN32
#define PIPE_READ_MODE "rb"
#define PIPE_WRITE_MODE "wb"
#else
#define PIPE_READ_MODE "r"
#define PIPE_WRITE_MODE "w"
#endif

// ======================
// external functions
// ======================
extern void merge_frames(int h, int w, unsigned char *, unsigned char *,
                         unsigned char *);
extern void merge_frames_asm(int h, int w, unsigned char *, unsigned char *,
                             unsigned char *);
extern void merge_frames_simd(int h, int w, unsigned char *, unsigned char *,
                              unsigned char *);

// ======================
// mode
// ======================
typedef enum { MODE_C = 1, MODE_ASM = 2, MODE_SIMD = 3, MODE_BENCH = 4 } Mode;

// ======================
// helpers
// ======================
static void ensure_dirs(void) {
#ifdef _WIN32
  _mkdir("output");
#else
  mkdir("output", 0755);
#endif
}

// ======================
// alloc
// ======================
static unsigned char *alloc_buf(void) {
#ifdef _WIN32
  return (unsigned char *)_aligned_malloc(N_BYTES, 32);
#else
  void *p = NULL;
  if (posix_memalign(&p, 32, N_BYTES) != 0)
    return NULL;
  return (unsigned char *)p;
#endif
}

static void free_buf(void *p) {
#ifdef _WIN32
  _aligned_free(p);
#else
  free(p);
#endif
}

// ======================
// timing
// ======================
static inline unsigned long long rdtsc(void) {
#ifdef _WIN32
  return __rdtsc();
#else
  unsigned int lo, hi;
  __asm__ volatile("rdtsc" : "=a"(lo), "=d"(hi));
  return ((unsigned long long)hi << 32) | lo;
#endif
}

// ======================
// FFmpeg helpers
// ======================
static FILE *ffmpeg_in(const char *cmd) {
  printf("[FFMPEG IN] %s\n", cmd);

  FILE *f = popen(cmd, PIPE_READ_MODE);
  if (!f)
    perror("ffmpeg_in failed");

  return f;
}

static FILE *ffmpeg_out(const char *cmd) {
  printf("[FFMPEG OUT] %s\n", cmd);

  FILE *f = popen(cmd, PIPE_WRITE_MODE);
  if (!f)
    perror("ffmpeg_out failed");

  return f;
}

// ======================
// RUN
// ======================
void run_mode(int mode) {
  ensure_dirs();

  unsigned char *a = alloc_buf();
  unsigned char *b = alloc_buf();
  unsigned char *out = alloc_buf();
  unsigned char *base = alloc_buf();

  if (!a || !b || !out || !base) {
    printf("Memory allocation failed\n");
    goto cleanup;
  }

  // NOTE:
  // Use ../vids when running from build directory (Linux/Windows safe)
  FILE *in1 = ffmpeg_in("ffmpeg -nostdin "
                        "-i ./vids/vid1_ready.mov "
                        "-vf scale=1796:738,format=rgb24,fps=60 "
                        "-f rawvideo -pix_fmt rgb24 pipe:1");

  FILE *in2 = ffmpeg_in("ffmpeg -nostdin "
                        "-i ./vids/vid2_ready.mov "
                        "-vf scale=1796:738,format=rgb24,fps=60 "
                        "-f rawvideo -pix_fmt rgb24 pipe:1");

  FILE *pipeout =
      popen("ffmpeg -y -nostdin "
            "-f rawvideo -pix_fmt rgb24 -s 1796x738 -r 60 -i pipe:0 "
            "-vf format=yuv420p "
            "-c:v libx264 -preset veryfast "
            "-movflags +faststart "
            "./output/output.mp4",
            PIPE_WRITE_MODE);

  if (!in1 || !in2 || !pipeout) {
    printf("FFmpeg pipe failed\n");

    if (in1)
      pclose(in1);
    if (in2)
      pclose(in2);
    if (pipeout)
      pclose(pipeout);

    goto cleanup;
  }

  unsigned long long t = 0;
  int frame = 0;

  while (1) {

    int r1 = fread(a, 1, N_BYTES, in1);
    int r2 = fread(b, 1, N_BYTES, in2);

    if (r1 != N_BYTES || r2 != N_BYTES)
      break;

    unsigned long long start = rdtsc();

    switch (mode) {

    case MODE_C:
      merge_frames(H, W, a, b, base);
      fwrite(base, 1, N_BYTES, pipeout);
      break;

    case MODE_ASM:
      merge_frames_asm(H, W, a, b, base);
      fwrite(base, 1, N_BYTES, pipeout);
      break;

    case MODE_SIMD:
      merge_frames_simd(H, W, a, b, base);
      fwrite(base, 1, N_BYTES, pipeout);
      break;

    case MODE_BENCH:
      merge_frames(H, W, a, b, base);
      merge_frames_asm(H, W, a, b, out);
      merge_frames_simd(H, W, a, b, out);
      fwrite(base, 1, N_BYTES, pipeout);
      break;

    default:
      printf("Invalid mode\n");
      goto cleanup;
    }

    t += rdtsc() - start;

    if (++frame % 30 == 0)
      printf("Frames: %d\r", frame);
  }

  printf("\nDONE\nCycles: %llu\n", t);

cleanup:

  if (in1)
    pclose(in1);
  if (in2)
    pclose(in2);
  if (pipeout)
    pclose(pipeout);

  free_buf(a);
  free_buf(b);
  free_buf(out);
  free_buf(base);
}

// ======================
// main
// ======================
int main(void) {
  int choice;

  printf("\n1) C\n2) ASM\n3) SIMD\n4) BENCH\n> ");

  if (scanf("%d", &choice) != 1)
    return 1;

  run_mode(choice);
  return 0;
}
