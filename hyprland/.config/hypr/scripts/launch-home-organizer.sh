#!/bin/bash
kitty -o allow_remote_control=yes --single-instance --instance-group organizer --title Tasks dooit &
kitty --instance-group organizer --title Calendar calcurse &
