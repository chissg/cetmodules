(function() {
  'use strict';

  var url_re = /fnalssi\.github\.io\/cetmodules\/(git-develop|latest|(v\d\.\d+))\//;
  var all_versions = {
    'git-develop': 'git-develop',
    'latest': 'latest release',
    'v3.07': '3.07',
  };

  function build_select(current_version, current_release) {
    var buf = ['<select>'];

    $.each(all_versions, function(version, title) {
      buf.push('<option value="' + version + '"');
      if (version == current_version) {
        buf.push(' selected="selected">');
        if (version[0] == 'v') {
          buf.push(current_release);
        } else {
          buf.push(title + ' (' + current_release + ')');
        }
      } else {
        buf.push('>' + title);
      }
      buf.push('</option>');
    });

    buf.push('</select>');
    return buf.join('');
  }

  function patch_url(url, new_version) {
    return url.replace(url_re, 'fnalssi.github.io/cetmodules/' + new_version + '/');
  }

  function on_switch() {
    var selected = $(this).children('option:selected').attr('value');

    var url = window.location.href,
        new_url = patch_url(url, selected);

    if (new_url != url) {
      // check beforehand if url exists, else redirect to version's start page
      $.ajax({
        url: new_url,
        success: function() {
           window.location.href = new_url;
        },
        error: function() {
           window.location.href = 'https://fnalssi.github.io/cetmodules/' + selected;
        }
      });
    }
  }

  $(document).ready(function() {
    var match = url_re.exec(window.location.href);
    if (match) {
      var release = DOCUMENTATION_OPTIONS.VERSION;
      var version = match[1];
      var select = build_select(version, release);
      $('.version_switch_note').html('Or, select a version from the drop-down menu above.');
      $('.version_switch').html(select);
      $('.version_switch select').bind('change', on_switch);
    }
  });
})();
