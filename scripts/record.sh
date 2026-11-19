#!/bin/bash
# Record demo-run.sh in Xvfb :99 at 1920x1080 / 30 fps, xterm filling the display.
set -euo pipefail
OUTDIR=/tmp/claude-skill-zip-demo
DISPLAY_NUM=99
export DISPLAY=:${DISPLAY_NUM}

pkill -f "Xvfb :${DISPLAY_NUM}" 2>/dev/null || true
pkill -f "xfwm4 --display :${DISPLAY_NUM}" 2>/dev/null || true
sleep 0.3

Xvfb :${DISPLAY_NUM} -screen 0 1920x1080x24 -nolisten tcp >/tmp/claude-skill-zip-demo/xvfb.log 2>&1 &
XVFB_PID=$!
sleep 0.4
if ! kill -0 "$XVFB_PID" 2>/dev/null; then
  echo "Xvfb failed" >&2
  cat /tmp/claude-skill-zip-demo/xvfb.log >&2
  exit 1
fi

xsetroot -solid '#0d1117'
xfwm4 --display :${DISPLAY_NUM} --compositor=off >/tmp/claude-skill-zip-demo/xfwm.log 2>&1 &
XFWM_PID=$!
sleep 0.5

ffmpeg -y -nostdin \
  -f x11grab -video_size 1920x1080 -framerate 30 -draw_mouse 0 -i :${DISPLAY_NUM}.0 \
  -c:v libx264 -pix_fmt yuv420p -preset medium -crf 18 \
  "$OUTDIR/out.mp4" >/tmp/claude-skill-zip-demo/ffmpeg.log 2>&1 &
FFMPEG_PID=$!
sleep 0.8

xterm -display :${DISPLAY_NUM} -fullscreen \
  -fa 'DejaVu Sans Mono' -fs 18 \
  -fg '#e6edf3' -bg '#0d1117' \
  +sb -bw 0 -b 12 +bc \
  -xrm '*faceName: DejaVu Sans Mono' \
  -xrm '*faceSize: 18' \
  -xrm '*fullscreen: true' \
  -e /bin/bash "$OUTDIR/demo-run.sh" &
XTERM_PID=$!
sleep 0.6
# Guarantee the window fills the framebuffer even if -fullscreen is ignored.
xdotool search --sync --class XTerm windowmove 0 0 windowsize 1920 1080 || true
wait "$XTERM_PID"
XTERM_EC=$?

sleep 0.8
kill -INT "$FFMPEG_PID" 2>/dev/null || true
wait "$FFMPEG_PID" 2>/dev/null || true
kill "$XFWM_PID" 2>/dev/null || true
kill "$XVFB_PID" 2>/dev/null || true
wait "$XFWM_PID" 2>/dev/null || true
wait "$XVFB_PID" 2>/dev/null || true

echo "xterm exit $XTERM_EC"
ls -la "$OUTDIR/out.mp4"
