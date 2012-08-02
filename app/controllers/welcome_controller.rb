class WelcomeController < ApplicationController
  helper :questions
  tabs :default => :welcome

  def fake_feedback
    render text: 'no', status: 404
  end

  def index
    @active_subtab = params.fetch(:tab, "activity")

    conditions = scoped_conditions({:banned => false})

    order = [:activity_at, :desc]
    case @active_subtab
      when "activity"
        order = [:activity_at, :desc]
      when "hot"
        order = "hotness desc"
        conditions[:updated_at] = {:$gt => 5.days.ago}
    end
    @langs_conds = @languages
    if logged_in?
      feed_params = { :feed_token => current_user.feed_token }
    else
      feed_params = { :lang => I18n.locale, :mylangs => current_languages }
    end
    add_feeds_url(url_for({:controller => 'questions', :action => 'index', :format => "atom"}.merge(feed_params)), t("feeds.questions"))

    @questions = Question.minimal.where(conditions).order_by(order).page(params["page"])
  end

  def feedback
  end

  def send_feedback
    ok = (recaptcha_valid? || logged_in?) &&
         !params[:feedback][:description].include?("[/url]")

    if ok && !params[:feedback][:email].blank? && params[:feedback][:title].split(" ").size < 3 &&
      single_words = params[:feedback][:description].split(" ").size
      ok = (single_words >= 3)

      links = words = 0
      params[:feedback][:description].split("http").map do |w|
        words += w.split(" ").size
        links += 1
      end

      if ok && links > 1 && words > 3
        ok = ((words-links) > 4)
      end
    end
    if params[:feedback][:description].include?("href") || params[:feedback][:description].size > 400
      render text: 'no', status: 404
      return
    end

    if !ok
      flash[:error] = I18n.t("welcome.feedback.captcha_error")
      flash[:error] += ". Domo arigato, Mr. Roboto. "
      redirect_to feedback_path(:feedback => params[:feedback])
    else
      flash[:notice] = I18n.t("welcome.feedback.captcha_notice")
      user = current_user || User.new(:email => params[:feedback][:email], :login => "Anonymous")
      Notifier.new_feedback(user, params[:feedback][:title],
                            params[:feedback][:description],
                            params[:feedback][:email],
                            request.remote_ip).deliver
      redirect_to root_path
    end
  end

  def change_language_filter
    if logged_in? && params[:language][:filter]
      current_user.language_filter = params[:language][:filter]
      current_user.save
    elsif params[:language][:filter]
      session["user.language_filter"] =  params[:language][:filter]
    end
    respond_to do |format|
      format.html {redirect_to(params[:source] || questions_path)}
    end
  end

  def confirm_age
    if request.post?
      session[:age_confirmed] = true
    end

    redirect_to params[:source].to_s[0,1]=="/" ? params[:source] : root_path
  end
end

