class Admin::ManageController < ApplicationController
  before_filter :login_required
  before_filter :check_permissions, :except => [:edit_card]
  layout "manage"
  tabs :dashboard => :dashboard,
       :properties => :properties,
       :content => :content,
       :actions => :actions,
       :stats => :stats,
       :widgets => :widgets

  subtabs :properties => [[:general, "general"],
                          [:rewards, "rewards"],
                          [:constrains, "constrains"],
                          [:theme, "theme"],
                          [:domain, "domain"]]
  subtabs :content => [[:question_prompt, "question_prompt"],
                       [:question_help, "question_help"],
                       [:head_tag, "head_tag"],
                       [:head, "head"], [:footer, "footer"],
                       [:top_bar, "top_bar"]]
  subtabs :social => [[:post_to_twitter, "post_to_twitter"],
                     [:ask_from_twitter, "ask_from_twitter"],
                     [:facebook_app, "facebook_app"],
                     [:twitter_account, "twitter_account"]]
  subtabs :invitations => [[:invite, "invite"],
                     [:invitations, "invitations"]]

  def dashboard
  end

  def edit_card
    if params[:group_id]
      @group = Group.find(params[:group_id])
    else
      @group = current_group
    end
    return unless current_user.owner_of?(@group)
    render :layout => 'invitations'
  end

  def properties
    @active_subtab ||= "general"
  end

  def appearance
  end

  def actions
  end

  def stats
  end

  def domain
  end

  def content
    @active_subtab ||= "head_tag"
    unless @group.has_custom_html
      flash[:error] = t("global.permission_denied")
      redirect_to domain_url(:custom => @group.domain, :controller => "manage",
                             :action => "properties", :tab => "constrains")
    end
  end

  def social
    @active_subtab ||= "post_to_twitter"
  end

  def invitations
    @active_subtab ||= "invite"
    @invitation = Invitation.new
  end

  def access
  end

  def close_group
  end

  protected
  def check_permissions
    @group = current_group

    if @group.nil?
      redirect_to groups_path
    elsif !current_user.owner_of?(@group) && !current_user.admin?
      flash[:error] = t("global.permission_denied")
      redirect_to domain_url(:custom => @group.domain)
    end
  end
end
