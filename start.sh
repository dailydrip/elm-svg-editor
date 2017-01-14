#!/bin/bash

elm-package install -y && \
  yarn && \
  npm run start
