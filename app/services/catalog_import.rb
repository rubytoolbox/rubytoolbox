# frozen_string_literal: true

class CatalogImport
  attr_accessor :catalog_data
  private :catalog_data=

  def initialize(catalog_data)
    self.catalog_data = catalog_data
  end

  def perform
    upsert_category_groups
    destroy_obsolete_category_groups
    destroy_obsolete_categories
  end

  private

  def upsert_category_groups
    category_group_data.each do |category_group_data|
      group = CategoryGroup.find_or_initialize_by(permalink: category_group_data["permalink"])
      group.update_attributes! name: category_group_data["name"],
                               description: category_group_data["description"]

      upsert_categories categories_data: category_group_data["categories"], group: group
    end
  end

  def upsert_categories(categories_data:, group:)
    categories_data.each do |category_data|
      category = Category.find_or_initialize_by(permalink: category_data["permalink"])
      category.update_attributes! name: category_data["name"],
                                  description: category_data["description"],
                                  category_group: group

      upsert_projects category_data["projects"]
    end
  end

  def upsert_projects(projects)
    projects.each do |project|
      Project.find_or_initialize_by(permalink: project).save!
    end
  end

  def destroy_obsolete_category_groups
    obsolete_groups = CategoryGroup.pluck(:permalink) - category_group_data.map { |g| g["permalink"] }
    obsolete_groups.each { |permalink| CategoryGroup.find(permalink).destroy }
  end

  def destroy_obsolete_categories
    obsolete_categories = Category.pluck(:permalink) - category_data.map { |g| g["permalink"] }
    obsolete_categories.each { |permalink| Category.find(permalink).destroy }
  end

  def category_group_data
    catalog_data["category_groups"]
  end

  def category_data
    @category_data ||= category_group_data.map { |g| g["categories"] }.flatten
  end
end
