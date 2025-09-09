# test ffmpeg:
time ffmpeg -fflags +genpts -threads auto -i fringe.mp4 -y -c:v copy -bsf:v h264_mp4toannexb -c:a copy -map 0:0 -map 0:1 -sn -f mpegts fringe.out.stf

nohup ./libogg.sh >> libogg.log 2>&1 &
nohup ./libvorbis.sh >> libvorbis.log 2>&1 &
nohup ./flac.sh >> flac.log 2>&1 &
nohup ./libpng.sh >> libpng.log 2>&1 &
nohup ./libtheora.sh >> libtheora.log 2>&1 &
nohup ./libvpx.sh >> libvpx.log 2>&1 &
nohup ./lame.sh >> lame.log 2>&1 &
nohup ./twolame.sh >> twolame.log 2>&1 &
nohup ./opus.sh >> opus.log 2>&1 &
nohup ./shine.sh >> shine.log 2>&1 &
nohup ./rtmpdump.sh >> rtmpdump.log 2>&1 &
nohup ./fribidi.sh >> fribidi.log 2>&1 &
nohup ./freetype.sh >> freetype.log 2>&1 &
nohup ./dejavu-fonts-ttf.sh >> dejavu-fonts-ttf.log 2>&1 &
nohup ./fontconfig.sh >> fontconfig.log 2>&1 &
nohup ./libass.sh >> libass.log 2>&1 &
nohup ./libwebp.sh >> libwebp.log 2>&1 &

# Now remove old ffmpeg package
funpkg -r ffmpeg

# Build  x264 and x265 first
nohup ./x264.sh >> x264.log 2>&1 &
nohup ./x265.sh >> x265.log 2>&1 &
nohup ./ffmpeg3.sh >> ffmpeg3.log 2>&1 &
# Link x264 to ffmpeg (recompile after ffmpeg build and install)
nohup ./x264.sh >> x264.log 2>&1 &
