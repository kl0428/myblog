function showCheck(a){
	var c = document.getElementById("myCanvas");
  var ctx = c.getContext("2d");
	ctx.clearRect(0,0,1000,1000);
	ctx.font = "80px 'Microsoft Yahei'";
	ctx.fillText(a,0,100);
	ctx.fillStyle = "white";
}
var code ;    
/*function createCode(){
    code = "";      
    var codeLength = 4;
    var selectChar = new Array(1,2,3,4,5,6,7,8,9,'a','b','c','d','e','f','g','h','j','k','l','m','n','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z');      
    for(var i=0;i<codeLength;i++) {
       var charIndex = Math.floor(Math.random()*60);      
      code +=selectChar[charIndex];
    }      
    if(code.length != codeLength){      
      createCode();      
    }
    showCheck(code);
}*/

function createCode()
{
    axios.get("/ause/flush",{headers:{'X-Requested-With': 'XMLHttpRequest'}}).then(function(response){
        console.log(response);
        if(response.data.success && response.data.code){
            //$("#J_codetext").val(response.data.code);
            showCheck(response.data.code);
        }
    }).catch(function(error){
        var err = 'Error! Could not reach the API. ' + error;
        console.log(err);
    });
}
          
function validate () {
    alert("validate");
    var inputCode = document.getElementById("J_codetext").value.toLowerCase();
    if(inputCode.length <=0) {
      document.getElementById("J_codetext").setAttribute("placeholder","输入验证码");
      createCode();
      return false;
    }else{
        axios.post("/ause/validateCode",{code:inputCode},{headers:{'X-Requested-With':'XMLHttpRequest'}}).then(function(response){
            if(response.data.success){
                window.open(document.getElementById("J_down").getAttribute("data-link"));
                document.getElementById("J_codetext").value="";
                createCode();
                return true;
            }else{
                document.getElementById("J_codetext").value="";
                document.getElementById("J_codetext").setAttribute("placeholder","验证码错误");
                createCode();
                return false;
            }
        }).catch(function(error){
            var err = 'Error! Could not reach the API. ' + error;
            console.log(err);
        });
    }

}