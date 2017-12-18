class InterviewerController < ApplicationController
  def freelancer_domains
    # raise params.inspect
    interviewer = Interviewer.new name:params[:name],email:params[:email],title:params[:title],skills:params[:skill_set],languages_set:params[:languages_set],skill_set:params[:skills],languages:params[:languages],expertise:params[:expertise],domain:params[:domain]
    # raise interviewer.inspect
    if interviewer.save

      render json:{success:true}
    else
    end
  end

  private

  def interviewer_params
    name:params[:name],email:params[:email],title:params[:title],skill_set:params[:skill_set],languages:params[:languages],expertise:params[:expertise]
  end
end
