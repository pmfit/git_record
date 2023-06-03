module GitRecord
  class GithubRepository < BaseRepository
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
      rescue
        false
      end
    end

    def update!(**attrs)
      raise StandardError, "Failed to update" unless update(**attrs)
    end

    def destroy
      begin
        @repo.destroy

        true
      rescue
        false
      end
    end

    def destroy!
      raise StandardError, "Failed to destroy" unless destroy
    end

    def staged(branch)
      tree_for_branch(branch).contents
    end

    def stage_content(branch, file)
      tree_for_branch(branch).add_file(
        file.path,
        file.content
      )
    end

    def unstage_content(branch, file)
      tree = tree_for_branch(branch)

      index = tree.contents.find_index { |item| item.path == file.path }

      if index.blank?
        return false
      else
        tree.contents = tree.contents.slice(index)

        return true
      end
    end
 
    def commit(message)
      new_tree = tree.dup

      GithubApi::Commit.create(message, new_tree.sha, full_name)
    end

    private

    def tree_for_branch(branch)
      @trees ||= {}

      return @tress[branch] if @trees[branch].present?

      branch = @repo.branch(branch)
      
      @trees[branch] = branch.commit.tree
    end
  end
end