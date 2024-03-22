function startChatbot(event) {
    event.preventDefault();  // Prevent the form from submitting through HTTP POST

    var participantId = document.getElementById('participant_id').value;
    // Redirect to the splash screen URL, passing the participant_id
    window.location.href = `/start/${participantId}/`;
}
