#!/bin/sh

tar -cf- -- * | ssh admin@keg.house tar -C docker -xf-
