date = null
auth = null

calculateSignature = (jqXHR, secret, settings) ->
  rep = canonicalRepresentation(jqXHR, settings)
  CryptoJS.HmacSHA256(rep, secret);

canonicalRepresentation = (jqXHR, settings) ->
  a = document.createElement("a")
  a.href = settings.url
  paramsStr = ''
  if a.search.length > 1
    paramsMap = for param in a.search.substr(1).split('&')
      param.split('=')
    paramsMap.sort (a, b) ->
      if a[0] < b[0]
        -1
      else if a[0] > b[0]
        1
      else
        0
    params = for param in paramsMap
      param.join('=')
    paramsStr = '?' + params.join('&')
  "GET\ndate:#{settings.headers["X-HMAC-DATE"]}\nnonce:#{settings.headers["X-HMAC-NONCE"] ? ''}\n#{a.pathname}#{paramsStr}"

successHandler = (data, textStatus, jqXHR) ->
  $('.main .status .status-text').text(textStatus + " - " + jqXHR.status).removeClass('bg-danger').addClass('bg-success')
  responseBlock = $('.main .result code')
  prettyData = JSON.stringify(data, null, 2)
  responseBlock.text(prettyData)
  hljs.highlightBlock(responseBlock.get(0))
  $('.headers tbody').empty().append("<tr><td>X-HMAC-DATE</td><td>#{date}</td></tr><tr><td>Authorization</td><td>#{auth}</td></tr>")


errorHandler = (jqXHR, textStatus, errorThrown) ->
  $('.main .status .status-text').text(textStatus + " - " + jqXHR.status + " " + errorThrown).addClass('bg-danger').removeClass('bg-success')
  $('.main .result .panel-body').text(jqXHR.responseText)

$('#submit-request').click (event) ->
  event.preventDefault();
  $('.main .status .status-text').text('').removeClass('bg-success bg-danger')
  $('.main .result .panel-body').text('')

  url = $('#web-api-url').val()
  url = url[0..-2] if url.match(/\/$/)

  accessId = $('#access-key-id').val()
  secret = $('#web-api-secrect').val()
  date = new Date().toUTCString()

  $.ajax(
    url: url
    success: successHandler
    dataType: 'json'
    crossDomain: true
    xhrFields: { withCredentials: true },
    headers:
      "X-HMAC-DATE": date
    beforeSend: (jqXHR, settings) ->
      auth = "HMAC #{accessId} #{calculateSignature(jqXHR, secret, settings)}"
      jqXHR.setRequestHeader("Authorization", auth)
      true
  ).fail(errorHandler)