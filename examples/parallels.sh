#!/bin/bash
sh run.sh ./env_cw_demo.json ./parallels_1.pql https://autoptic.io/pql/ep/b961f7d5-5003-4177-ab25-e3268237880c/run > /tmp/parallels1.`date +%s`.json 2>&1 &
sh run.sh ./env_cw_demo.json ./parallels_2.pql https://autoptic.io/pql/ep/b961f7d5-5003-4177-ab25-e3268237880c/run > /tmp/parallels2.`date +%s`.json 2>&1 &
sh run.sh ./env_cw_demo.json ./parallels_3.pql https://autoptic.io/pql/ep/b961f7d5-5003-4177-ab25-e3268237880c/run > /tmp/parallels3.`date +%s`.json 2>&1 &
sh run.sh ./env_cw_demo.json ./parallels_4.pql https://autoptic.io/pql/ep/b961f7d5-5003-4177-ab25-e3268237880c/run > /tmp/parallels4.`date +%s`.json 2>&1 &

