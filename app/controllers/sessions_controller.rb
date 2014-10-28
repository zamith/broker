class SessionsController < Clearance::SessionsController
  def new
    if signed_in?
      redirect_to dists_path
      return
    end
  end
end
