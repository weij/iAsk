class SearchesController < ApplicationController
  before_filter :login_required, :except => %w[index]
  before_filter :track_pageview

  subtabs :index => [[:newest, %w(created_at desc)], [:hot, [%w(hotness desc), %w(views_count desc)]], [:votes, %w(votes_average desc)], [:activity, %w(activity_at desc)], [:expert, %w(created_at desc)]],
          :unanswered => [[:newest, %w(created_at desc)], [:votes, %w(votes_average desc)], [:mytags, %w(created_at desc)]],
          :show => [[:votes, %w(votes_average desc)], [:oldest, %w(created_at asc)], [:newest, %w(created_at desc)]]

  def index
    options = {}
    unless params[:q].blank?
      pharse = params[:q]
      @search_tags = pharse.scan(/\[(\w+)\]/).flatten
      @search_text = pharse.gsub(/\[(\w+)\]/, "")
      options[:tags] = @search_tags unless @search_tags.empty?
      options[:group_id] = current_group.id
      options[:banned] = false

      if params[:language]
        pharse += " lang:#{params[:language]}"
      end

      if params[:accepted]
        pharse += " is:accepted"
      end

      if params[:answered]
        pharse += " is:answered"
      end

      @search = Search.new(:query => pharse)

      if !@search_text.blank? #FIXME make tag search work with xapit || !@search_tags.empty?
        # FIXME:filter is blocking mongodb
        # @questions = Question.(@search_text, options)

        @questions = Question.search(@search_text).where(options).page(params["page"])

        # @questions = Question.filter(@search_text, options)
        # @highlight = @questions.parsed_query[:tokens].to_a
        # @questions = Question.where(options).page(params["page"])
        @highlight = ""
      else
        @questions = Question.where(options).page(params["page"])
        if !@search_tags.blank?
          @questions = Question.where(options.merge({:tags=>{:$all =>@search_tags}})).page(params["page"])
        end
      end
    else
      @questions = []
    end

    respond_to do |format|
      format.html
      format.js do
        render :json => {:html => render_to_string(:partial => "questions/question",
                                                   :collection  => @questions)}.to_json
      end
      format.json { render :json => @questions.to_json(:except => %w[_keywords slugs watchers]) }
    end
  end

  def show
    @search = current_user.searches.by_slug(params[:id], :group_id => current_group.id)
    if @search.nil?
      redirect_to search_index
    end

    find_questions(@search.conditions)
  end

  def create
    @search = Search.new
    @search.safe_update(%w[name query], params[:search])
    @search.user = current_user
    @search.group = current_group

    respond_to do |format|
      if @search.save
        format.html { redirect_to search_path(@search) }
      else
        format.html do
          params[:q] = @search.query
          render 'index'
        end
      end
    end
  end

  def destroy
    @search = current_user.searches.by_slug(params[:id], :group_id => current_group.id)
    @search.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end
end
