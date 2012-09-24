require 'spec_helper'

describe VotesController do
  include Devise::TestHelpers

  describe "Vote for question" do

    before (:each) do
      #stub_group
      #@group = Fabricate(:group)
      @group = stub_group
      @user = Fabricate(:user)
      @question_owner = Fabricate(:user)
      @user.join!(@group)
      @question_owner.join!(@group)
      @user.update_reputation(120, @group)
      @question_owner.update_reputation(100, @group)
      @user.reload
      stub_authentication @user
      @voteable = Fabricate(:question, :user => @question_owner, :group => @group)
    end

    describe "POST 'create'" do
      before(:each) do
        stub_group(@voteable.group)
      end

      it "should be successful" do
        @vote_attrs = {"vote_up" => 1, :question_id => @voteable.id}
        post 'create', @vote_attrs
        response.should redirect_to root_path
      end

      it "should be successful for js format" do
        @vote_attrs = {"vote_up" => 1, :question_id => @voteable.id, :format => "js"}
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 1
        @question_owner.reputation_on(@group).should == 102

        other_user = Fabricate(:user)
        other_user.join!(@group)
        other_user.update_reputation(60, @group)
        stub_authentication(other_user)
        @vote_attrs = {"vote_up" => 1, :question_id => @voteable.id, :format => "js"}
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 2
        @question_owner.reputation_on(@group).should == 104
      end

      it "should revoke the vote" do
        @vote_attrs = {"vote_up" => 1, :question_id => @voteable.id, :format => "js"}
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 1
        @question_owner.reputation_on(@group).should == 102

        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 0
        @question_owner.reputation_on(@group).should == 100
      end

      it "should change the vote" do
        @vote_attrs = {"vote_up" => 1, :question_id => @voteable.id, :format => "js"}
        post 'create', @vote_attrs

        @vote_attrs.delete("vote_up")
        @vote_attrs["vote_down"] = 1
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == -1
        @question_owner.reputation_on(@group).should == 99

        @vote_attrs.delete("vote_down")
        @vote_attrs["vote_up"] = 1
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 1
        @question_owner.reputation_on(@group).should == 102
      end
    end

  end

  describe "Vote for answer" do

    before (:each) do
      #stub_group
      #@group = Fabricate(:group)
      @group = stub_group
      @user = Fabricate(:user)
      @answer_owner = Fabricate(:user)
      @user.join!(@group)
      @answer_owner.join!(@group)
      @user.update_reputation(120, @group)
      @answer_owner.update_reputation(100, @group)
      @user.reload
      stub_authentication @user
      @question = Fabricate(:question, :group => @group)
      @voteable = Fabricate(:answer, :user => @answer_owner, :group => @group, :question => @question)
    end

    describe "GET 'index'" do
      it "should redirect to root path" do
        get 'index'
        response.should redirect_to root_path
      end
    end

    describe "POST 'create'" do
      before(:each) do
        stub_group(@voteable.group)
        @vote_attrs = {"vote_up" => 1, :question_id => @voteable.question_id}
      end

      it "should be successful" do
        @vote_attrs.merge!(:answer_id => @voteable.id)
        post 'create', @vote_attrs
        response.should redirect_to root_path
      end

      it "should be successful for js format" do
        @vote_attrs.merge!(:answer_id => @voteable.id, :format => "js")
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 1
        @answer_owner.reputation_on(@group).should == 102

        other_user = Fabricate(:user)
        other_user.join!(@group)
        other_user.update_reputation(60, @group)
        stub_authentication(other_user)
        @vote_attrs.merge!(:answer_id => @voteable.id, :format => "js")
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 2
        @answer_owner.reputation_on(@group).should == 104
      end

      it "should revoke the vote" do
        @vote_attrs.merge!(:answer_id => @voteable.id, :format => "js")
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 1
        @answer_owner.reputation_on(@group).should == 102

        @vote_attrs.merge!(:answer_id => @voteable.id, :format => "js")
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 0
        @answer_owner.reputation_on(@group).should == 100
      end

      it "should change the vote" do
        @vote_attrs.merge!(:answer_id => @voteable.id, :format => "js")
        post 'create', @vote_attrs

        @vote_attrs.delete("vote_up")
        @vote_attrs["vote_down"] = 1
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == -1
        @answer_owner.reputation_on(@group).should == 99

        @vote_attrs.delete("vote_down")
        @vote_attrs["vote_up"] = 1
        post 'create', @vote_attrs
        body = JSON.load(response.body)
        body["average"].should == 1
        @answer_owner.reputation_on(@group).should == 102
      end
    end
  end
end
