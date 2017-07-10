# The controller for returning API software version information
class VersionController < ApplicationController
  include ActionController::MimeResponds

  def show
    @version = Version.new

    respond_to do |format|
      format.html { render :show, status: :ok }
      format.json { render json: @version.release, status: :ok }
    end
  end
end
