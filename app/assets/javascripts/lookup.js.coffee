$(document).ready ->
  TIMEOUT = null
  TIMEOUT_SECS = 0
  $('body').on 'change', 'input#isbn_field', ->
    clearTimeout TIMEOUT
    TIMEOUT = setTimeout((->
      ajaxResponse = $.ajax(
        url: '/listings/lookup'
        type: 'GET'
        data:
          isbn: $('input#isbn_field').val())
      ajaxResponse.success (data) ->
        $('#isbn-lookup-results-container').html data
        $('#form-unfilled').hide()
        return
      ajaxResponse.error (data) ->
        alert 'Not a valid ISBN'
        return
      return
    ), TIMEOUT_SECS)
    return
  return
