# frozen_string_literal: true

# Store version in a constant so that we can refer to it from anywhere without having to
# read the VERSION file in real time.
APP_VERSION = File.read(Rails.root.join('VERSION'))

# Load Triclops config
VOYAGER_CONFIG = Rails.application.config_for(:voyager)
