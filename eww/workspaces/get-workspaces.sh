#!/usr/bin/env bash

# define colors
colors=("#FFFFFF" "#fab387" "#a6e3a1" "#89b4fa") # Active Workspaces
dimmed=("rgba(174,172,182,0.7)" "#f9e2af" "#94e2d5" "#b4befe") # Inactive workspaces
empty='rgba(146,145,145,0.5)' # Empty workspaces

# get initial focused workspace
focusedws=$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

declare -A o=([1]=0 [2]=0 [3]=0 [4]=0 [5]=0 [6]=0 [7]=0 [8]=0 [9]=0 [10]=0 [11]=0 [12]=0 [13]=0)
declare -A monitormap
declare -A workspaces
declare -A wsnames=([1]='~' [2]='1' [3]='2' [4]='3' [5]='4' [6]='5' [7]='6' [8]='7' [9]='8' [10]='9' [11]='0' [12]='-' [13]='+')

# set color for each workspace
status() {
  if [ "${o[$1]}" -eq 1 ]; then 
    mon=${monitormap[${workspaces[$1]}]}
    echo -n "workspace-text-nonempty"
  else
    echo -n "workspace-text-empty"
  fi
}

status_activity() {
  if [ "${o[$1]}" -eq 1 ]; then 
    mon=${monitormap[${workspaces[$1]}]}

    if [ $focusedws -eq "$1" ]; then
      echo -n "active"
    else
      echo -n "inactive"
    fi
  else
    echo -n "empty"
  fi
}

# handle workspace create/destroy
workspace_event() {
  if (( $1 <= 13 )); then
    o[$1]=$2
    while read -r k v; do workspaces[$k]="$v"; done < <(hyprctl -j workspaces | jq -r '.[]|"\(.id) \(.monitor)"')
  fi
  if [ "$2" == "0" ]; then
    unset "workspaces[$1]"
  fi
}
# handle monitor (dis)connects
monitor_event() {
  while read -r k v; do monitormap["$k"]=$v; done < <(hyprctl -j monitors | jq -r '.[]|"\(.name) \(.id) "')
}

# generate the json for eww
generate() {
  echo -n '['

  for i in {1..13}; do
    echo -n ''$([ $i -eq 1 ] || echo ,)'{"num":"'$i'","cls":"'$(status "$i")'"}'
    # echo -n ''$([ $i -eq 1 ] || echo ,) '{ "number": "'"$i"'", "activity": "'"$(status_activity $i)"'", "color": "'$(status "$i")'" }'
  done

  # echo -n ',{"num":"'$focusedws'","clr":"'$(status "$focusedws")'"}'

  echo ']'
}

# setup

# add monitors
monitor_event

# add workspaces
while read -r k v; do workspaces[$k]="$v"; done < <(hyprctl -j workspaces | jq -r '.[]|"\(.id) \(.monitor)"')

# check occupied workspaces
for num in "${!workspaces[@]}"; do
  o[$num]=1
done
# generate initial widget
generate

socat -u UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - | while read -r line; do
  # echo "${#workspaces[@]} ${#o[@]}"
  # echo $line
  case ${line%>>*} in
    "focusedmon")
      focusedws=${line#*,}
      generate
      ;;
    "createworkspace")
      # workspace_event "${line#*>>}" 1
      o=([1]=0 [2]=0 [3]=0 [4]=0 [5]=0 [6]=0 [7]=0 [8]=0 [9]=0 [10]=0 [11]=0 [12]=0 [13]=0)
      workspaces=()
      # add workspaces
      while read -r k v; do workspaces[$k]="$v"; done < <(hyprctl -j workspaces | jq -r '.[]|"\(.id) \(.monitor)"')
      # check occupied workspaces
      for num in "${!workspaces[@]}"; do
        o[$num]=1
      done
      # focusedws=${line#*>>}
      generate
      ;;
    "movewindow")
      generate
      ;;
    "destroyworkspace")
      # workspace_event "${line#*>>}" 0
      o=([1]=0 [2]=0 [3]=0 [4]=0 [5]=0 [6]=0 [7]=0 [8]=0 [9]=0 [10]=0 [11]=0 [12]=0 [13]=0)
      workspaces=()
      # add workspaces
      while read -r k v; do workspaces[$k]="$v"; done < <(hyprctl -j workspaces | jq -r '.[]|"\(.id) \(.monitor)"')
      # check occupied workspaces
      for num in "${!workspaces[@]}"; do
        o[$num]=1
      done
      generate
      ;;
    "monitor"*)
      monitor_event
      generate
      ;;
  esac
  # echo $line
  # generate
done
