exports.handler = function(event, context) {
    event.response.autoConfirmUser = true;
    context.done(null, event);
};