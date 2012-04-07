function showRepoDetails() {
  var $repo = $(this)
    , repoName = $repo.data('repo_name')

  $.ajax(
      'https://api.github.com/repos/'+repoName
    , {
        dataType: 'jsonp'
      , success: function(repo) {
          var $description = $repo.find('.description')
            , $wathers = $repo.find('.watchers')

          $description.text(repo.data.description);
          $wathers.text('['+repo.data.watchers+']');
      }
    }
  );
}
