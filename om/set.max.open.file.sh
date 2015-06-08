#!/bin/bash
#

echo '* soft nofile 102400' >> /etc/security/limits.conf
echo '* hard nofile 102400' >> /etc/security/limits.conf
echo 'session    required     pam_limits.so' >> /etc/pam.d/login
