#!/bin/bash
#
ssh root@hdc-63 "impala-shell -q 'invalidate metadata'"
