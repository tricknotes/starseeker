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
            , data = repo.data

          $description.text(data.description);

          $linkToWatchers.attr('href', data.html_url + '/watchers');
          $linkToWatchers.text('['+data.watchers+']');
          $wathers.html($linkToWatchers);
      }
    }
  );
}
