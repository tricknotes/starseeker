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
            , $linkToWatchers = $('<a/>')

          $description.text(repo.data.description);

          $linkToWatchers.attr('href', repo.data.html_url + '/watchers');
          $linkToWatchers.text('['+repo.data.watchers+']');
          $wathers.html($linkToWatchers);
      }
    }
  );
}
