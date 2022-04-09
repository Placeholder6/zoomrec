# Start xfce4
${START_DIR}/xfce.sh &> "$START_DIR"/xfce.log

# Cleanup to ensure pulseaudio is stateless
rm -rf /var/run/pulse /var/lib/pulse /home/zoomrec/.config/pulse

# Start audio
pulseaudio -D --exit-idle-time=-1 --log-level=error

# Create dummy audio output
pactl load-module module-null-sink sink_name=dummy sink_properties=device.description="dummy" > /dev/null
pactl set-source-volume 1 100%

echo -e "\nStart script.."
sleep 5

# Start python script in separated terminal
if [[ "$DEBUG" == "True" ]]; then
  # Wait if something failed
  xfce4-terminal -H --geometry 85x7+0 --title=zoomrec --hide-toolbar --hide-menubar --hide-scrollbar --hide-borders --zoom=-3 -e "python3 -u ${HOME}/zoomrec.py"
else
  # Exit container if something failed
  xfce4-terminal --geometry 85x7+0 --title=zoomrec --hide-toolbar --hide-menubar --hide-scrollbar --hide-borders --zoom=-3 -e "python3 -u ${HOME}/zoomrec.py"
fi
