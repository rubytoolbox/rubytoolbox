# frozen_string_literal: true

class CatalogImport
  # A shorthand for `new(data).perform`, mostly to ease
  # spec call assertions
  def self.perform(catalog_data)
    new(catalog_data).perform
  end

  attr_accessor :catalog_data
  private :catalog_data=

  def initialize(catalog_data)
    self.catalog_data = catalog_data
  end

  def perform
    upsert_category_groups
    destroy_obsolete_category_groups
    destroy_obsolete_categories
    link_projects_to_categories
    destroy_obsolete_categorizations
  end

  private

  def category_group_data
    catalog_data["category_groups"]
  end

  def category_data
    @category_data ||= category_group_data.map { |g| g["categories"] }.flatten
  end

  def project_data
    @project_data ||= category_data.map { |c| c["projects"] }.flatten.uniq
  end

  def upsert_category_groups
    category_group_data.each do |category_group_data|
      group = CategoryGroup.find_or_initialize_by(permalink: category_group_data["permalink"])
      group.update_attributes! name: category_group_data["name"],
                               description: category_group_data["description"]

      upsert_categories categories_data: category_group_data["categories"], group: group
    end
  end

  def destroy_obsolete_category_groups
    obsolete_groups = CategoryGroup.pluck(:permalink) - category_group_data.map { |g| g["permalink"] }
    obsolete_groups.each { |permalink| CategoryGroup.find(permalink).destroy }
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

  def destroy_obsolete_categories
    obsolete_categories = Category.pluck(:permalink) - category_data.map { |g| g["permalink"] }
    obsolete_categories.each { |permalink| Category.find(permalink).destroy }
  end

  def upsert_projects(projects)
    projects.each do |project|
      Project.find_or_initialize_by(permalink: project).save!
    end
  end

  def link_projects_to_categories
    project_data.each do |project_permalink|
      Project.find(project_permalink).update_attributes! categories: categories_for_project_permalink(project_permalink)
    end
  end

  def categories_for_project_permalink(project_permalink)
    relevant_category_permalinks = category_data
                                   .select { |c| c["projects"].include? project_permalink }
                                   .map { |c| c["permalink"] }
    Category.where(permalink: relevant_category_permalinks)
  end

  def destroy_obsolete_categorizations
    Categorization.where.not(project_permalink: project_data).destroy_all
  end
end
