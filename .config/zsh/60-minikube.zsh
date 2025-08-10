#!/bin/sh

tmux has-session -t minikube-tunnel 2>/dev/null || tmux new-session -d -s minikube-tunnel 'minikube tunnel'

