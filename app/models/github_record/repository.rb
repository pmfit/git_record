module GithubRecord
  class Repository < BaseRepository
    attribute :default_branch, :string

    def initialize(**attributes)
      @repo = attributes.delete(:repo)

      super(**attributes)
    end

    def self.find(full_name)
      repo = GithubApi::Repository.find(full_name)

      self.new(
        full_name: repo.full_name,
        name: repo.name,
        url: repo.url,
        repo: repo
      )
    end

    def update(name:, description: nil)
      begin
        @repo = @repo.update(name:, description:)
        
        true
      rescue StandardError => e
        errors.add(:base, e.message)

        false
      end
    end

    def update!(**attrs)
      raise StandardError, errors(:base) || "Failed to update" unless update(**attrs)
    end

    def destroy
      begin
        @repo.destroy

        true
      rescue StandardError => e
        errors.add(:base, e.message)

        false
      end
    end

    def destroy!
      raise StandardError, errors(:base) || "Failed to destroy" unless destroy
    end

    def find(path, branch: nil)

    end

    def staged(branch)
      tree_for_branch(branch).contents
    end

    def stage_content(branch, contents = [])
      contents.each do |content|
        tree_for_branch(branch).add_file(
          content.path,
          content.content
        )
      end
    end

    def unstage_content(branch, content)
      tree = tree_for_branch(branch)

      index = tree.contents.find_index { |item| content.path == item.path }

      if index.blank?
        return false
      else
        tree.contents = tree.contents.slice(index)

        return true
      end
    end
 
    def commit(branch_name, message)
      branch = @repo.branch(branch_name)
      new_tree = tree_for_branch(branch_name).dup
      new_commit = GithubApi::Commit.create(message, new_tree.sha, full_name, parents: [branch.sha])
      
      branch.update(new_commit.sha)

      @trees[branch_name] = nil

      true
    rescue StandardError => e
      errors(:tree, e.message)

      false
    end
    
    def commit!(branch, message)
      raise StandardError, errors(:tree) || "Failed to commit to #{branch}" unless commit(branch, message)
    end

    private

    def tree_for_branch(branch_name)
      if @trees.present? && @trees[branch_name].present?
        return @trees[branch_name]
      end

      @trees ||= {}

      branch = @repo.branch(branch_name)
      tree = branch.commit.tree
      
      @trees[branch_name] = tree

      @trees[branch_name]
    end
  end
end