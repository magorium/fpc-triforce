unit akeyboard;


// keyboard.device unit for AROS


interface


uses
  exec;


const
  KBD_READEVENT               = (CMD_NONSTD + 0);
  KBD_READMATRIX              = (CMD_NONSTD + 1);
  KBD_ADDRESETHANDLER         = (CMD_NONSTD + 2);
  KBD_REMRESETHANDLER         = (CMD_NONSTD + 3);
  KBD_RESETHANDLERDONE        = (CMD_NONSTD + 4);


implementation


end.
