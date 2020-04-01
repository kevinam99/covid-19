$(document).ready(function () {
    $('#form').on('submit', function (ev) {

        // prevent from auto-submitting  
        ev.preventDefault();
        ev.stopPropagation();

        // if all is good, then submit.
        sendData();

    });

    var validatePhoneNumber = function (phoneNumber) {

        if (phoneNumber[0] == 0 && phoneNumber.length == 11) {
            phoneNumber = `+91${phoneNumber.slice(1)}`
        }

        if (phoneNumber.length == 10) {
            phoneNumber = `+91${phoneNumber}`
        }

        var regex = /^\+[1-9]\d{1,14}$/i;

        if (!regex.test(phoneNumber)) {
            return false
        }
        return phoneNumber
    }

    var validatePin = function (pin) {

        if (pin.length != 6) {
            return false
        }

        return pin
    }

    //function to send data to the PHP script
    var sendData = function () {
        var pin = $('#pin').val();
        var phone = $('#phone').val();

        phone = validatePhoneNumber(phone)
        pin = validatePin(pin)

        if (!phone) {
            $('#messageText').text("Phone number should match format +91<10 digits>");
            $("#messageText").css('color', 'red');
            
            $('#phone').focus();
            return;
        };

        if (!pin) {
            $('#messageText').text("Pin should be 6 digits");
            $("#messageText").css('color', 'red');
            
            $('#pin').focus();
            return;
        };

        $.ajax({
            type: "post",
            url: "http://coronadailyupdates.org/api/users",
            data: {
                "pincode": pin,
                "phone": phone
            },
            cache: false,
            complete: function () {
                $('#form').hide();
                $('#error').hide();
                $('#duplicate').hide();
                $('#phoneError').hide();
                $('#pinError').hide();
                $('#success').show();

                $('#form').hide();
                $('#messageText').show();
                $('#messageText').text("Subscribed. Stay Safe! ");
                $("#messageText").css('color', 'green');
            },
            error: function (xhr, textStatus, error) {
                $('#form').hide();
                $('#messageText').show();
                $('#messageText').text("Sorry something went wrong. Please retry");
                $("#messageText").css('color', 'red');
                console.log(xhr.statusText);
                console.log(textStatus);
                console.log(error);
            },
        });

        return;
    };

});