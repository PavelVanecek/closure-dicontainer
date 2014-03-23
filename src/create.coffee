###*
  @param {Function} createIntro
  @param {Function} createBody
  @param {Function} createOutro
  @return {string} Generated DI container source code.
###
module.exports = (createIntro, createBody, createOutro) ->

  ->
    body = createBody()
    code = [
      createIntro body.required
      body.src
      createOutro()
    ].join '\n\n'
    
    code: code
    required: body.required
