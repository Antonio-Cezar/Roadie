#!/usr/bin/env bash

while true; do
  echo "=========================="
  echo "       RoadIe MENU         "
  echo "=========================="
  echo "1) ..."
  echo "2) ..."
  echo "3) ..."
  echo "4) ..."
  echo "5) Exit"
  echo

  read -r -p "Select an option [1-5]: " choice

  case "$choice" in
    1)
      ;;
    2)
      ;;
    3)
      ;;
    4)
      ;;
    5)
      exit 0
      ;;
    *)
      echo "Invalid choice."
      sleep 1
      ;;
  esac
done