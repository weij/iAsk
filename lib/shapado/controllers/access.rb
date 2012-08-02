module Shapado
  module Controllers
    module Access
      def self.included(base)
        base.class_eval do
          helper_method :logged_in?
        end
      end

      def logged_in?
        user_signed_in?
      end

      def check_group_access
        return if !current_group

        if ((!current_group.registered_only || is_bot?) && !current_group.shapado_version.is_private?) || devise_controller? || (params[:controller] == "users" && action_name == "new" )
          return
        end

        if logged_in?
          if !current_user.user_of?(@current_group)
#             if cookie = cookie[:accept_invitation] FIXME
#               current_user.accept_invitation(cookie)
#             end
            cookies["pp"] = nil
            redirect_to '/users/logout'
            #raise Goalie::Forbidden
          end
        else
          respond_to do |format|
            format.json { render :json => {:message => "Permission denied" }}
            format.html { redirect_to new_user_session_path }
          end
        end
      end

      def admin_required
        unless current_user.admin?
          raise Goalie::Forbidden
        end
      end

      def moderator_required
        unless current_user.mod_of?(current_group)
          raise Goalie::Forbidden
        end
      end

      def owner_required
        unless current_user.owner_of?(current_group)
          raise Goalie::Forbidden
        end
      end

      def login_required
        respond_to do |format|
          format.js do
            if warden.authenticate(:scope => :user).nil?
              return render(:json => {:message => t("global.please_login"),
                                                :success => false,
                                                :status => :unauthenticate}.to_json)
            end
          end
          format.any { warden.authenticate!(:scope => :user) }
        end
      end

      def after_sign_out_path_for(resource)
        params[:format] == "mobile" ? "/questions.mobile" : root_path
      end

      def after_sign_in_path_for(resource)
        if current_user.admin?
          Jobs::Activities.async.on_admin_connect(request.remote_ip, current_user.id).commit!
        end

        current_user.check_social_friends
        # check if cookie pp is set
        # if true this means user logged in through popup
        if cookies["pp"] && params[:format] != 'mobile'
          cookies.delete :pp
          '/close_popup.html'
        elsif params[:format] == 'mobile'
          '/questions.mobile'
        else
          cookies.delete :pp
          if return_to = stored_location_for(:user)
            return_to
          else
            super
          end
        end
      end
    end
  end
end
