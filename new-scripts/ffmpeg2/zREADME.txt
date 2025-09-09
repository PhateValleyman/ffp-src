test:
time ffmpeg -fflags +genpts -threads auto -i fringe.mp4 -y -c:v copy -bsf:v h264_mp4toannexb -c:a copy -map 0:0 -map 0:1 -sn -f mpegts fringe.out.stf

nohup ./x264.sh >> x264.log 2>&1 &
nohup ./ffmpeg2.sh >> ffmpeg2.log 2>&1 &
Link x264 to ffmpeg (recompile after ffmpeg build)
nohup ./x264.sh >> x264.log 2>&1 &
nohup ./fontconfig.sh >> fontconfig.log 2>&1 &
nohup ./rtmpdump.sh >> rtmpdump.log 2>&1 &
