# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    render plain: "This is Voyager Query #{APP_VERSION}."
  end
end
