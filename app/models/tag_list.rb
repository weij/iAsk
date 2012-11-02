class TagList
  include Mongoid::Document

  field :_id, :type => String
  field :group_id, :type => String
  belongs_to :group

  field :tags, :type => Hash

  def self.add_tags(group_id, *tags)
    toinc = {"tags" => {}}
    tags.each do |tag|
      toinc["tags.#{tag.gsub('.', '%dot%')}"] = 1
    end
    self.collection.update({:group_id => group_id}, {:$inc => toinc})
  end

  def add_tags(*tags)
    self.class.add_tags(self.group_id, *tags)
  end
end
