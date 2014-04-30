date = null
auth = null

calculateSignature = (jqXHR, secret, settings) ->
  rep = canonicalRepresentation(jqXHR, settings)
  CryptoJS.HmacSHA256(rep, secret);

canonicalRepresentation = (jqXHR, settings) ->
  a = document.createElement("a")
  a.href = settings.url
  "GET\ndate:#{settings.headers["X-HMAC-DATE"]}\nnonce:#{settings.headers["X-HMAC-NONCE"] ? ''}\n#{a.pathname}"

successHandler = (data, textStatus, jqXHR) ->
  $('.main .status .status-text').text(textStatus + " - " + jqXHR.status).removeClass('bg-danger').addClass('bg-success')
  responseBlock = $('.main .result code')
  prettyData = JSON.stringify(data, null, 2)
  console.log(prettyData)
  responseBlock.text(prettyData)
  hljs.highlightBlock(responseBlock.get(0))
  $('.headers tbody').empty().append("<tr><td>X-HMAC-DATE</td><td>#{date}</td></tr><tr><td>Authorization</td><td>#{auth}</td></tr>")


errorHandler = (jqXHR, textStatus, errorThrown) ->
  $('.main .status .status-text').text(textStatus + " - " + jqXHR.status + " " + errorThrown).addClass('bg-danger').removeClass('bg-success')
  $('.main .result .panel-body').text(jqXHR.responseText)

$('#submit-request').click (event) ->
  event.preventDefault();

  url = $('#web-api-url').val()
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