program Hyper_Text_Install;
{
Auteur: Patrick Premartin.
Date: (1.0) 30/12/1991.
      (1.1) 31/07/1992.
Langage: Turbo Pascal 6.0
But: Modification de HTRUN (aprŠs copie) pour qu'il lance par d‚faut le fichier
     .HTD sp‚cifi‚.
}
uses
    dos,
    olf_software,
    u_file,
    u_m_util,
    u_msg,
    u_sgf;

const
     num_vers = '1.0';
     dat_vers = '07/31/1992';

var
   ht_run,
   nom_fich : string;
   name : namestr;

function find : boolean;
var
   dir : dirstr;
   ext : extstr;
begin
     fsplit (nom_fich, dir, name, ext);
     nom_fich := dir+name+'.EXE';
     if (dir [length (dir)] = '\')
     then
         dec (dir [0]);
     {endif}
     ht_run := fsearch ('HTRUN.EXE', dir+';'+getenv ('PATH'));
     find := (ht_run <> '');
end; { Find }

function modify : boolean;
var
   fich : file;
   pt,
   tampon : pointer;
   i,
   nb : longint;
   ch : string [12];
   ok : boolean;
begin
     assign (fich, nom_fich);
     reset (fich, 1);
     nb := filesize (fich);
     getmem (tampon, nb);
     if (tampon = nil)
     then
         alert ('Error: Not Enough Memory to continue, contact the coder...', al_error)
     else
         begin
              blockread (fich, tampon^, nb);
              close (fich);
              i := -1;
              repeat
                    inc (i);
                    pt := ptr (seg (tampon^), ofs (tampon^)+i);
                    move (pt^, ch, sizeof (ch));
              until ((i > nb-12) or (ch = 'HTPREPAT.HTD'));
              if (ch <> 'HTPREPAT.HTD')
              then
                  ok := false
              else
                  begin
                       ch := name+'.HTD';
                       move (ch, pt^, sizeof (ch));
                       rewrite (fich, 1);
                       blockwrite (fich, tampon^, nb);
                       close (fich);
                       ok := true;
                  end;
              {endif}
              freemem (tampon, nb);
         end;
     {endif}
end; { Modify }

begin
     init_licence ('mkht');
     init_olf_message (mess_shareware);
     init_ligne_olf_software ('Hyper Texte Maker: Install '+num_vers, #155' Patrick Premartin '+dat_vers);
     nom_fich := '';
     alert (get_msg (44), al_wait);
     nom_fich := get_fich_name (nom_fich, 'HTD');
     if not (exist (nom_fich))
     then
         alert ('Error: '+nom_fich+' does not exist...', al_error)
     else
         if not find
         then
             alert ('Error: I can not find HTRUN.EXE...', al_error)
         else
             if not copy_file (ht_run, nom_fich)
             then
                 alert ('Error: I can not copy HTRUN...', al_error)
             else
                 if not modify
                 then
                     alert ('Error: I can not install '+nom_fich, al_error);
                 {endif}
             {endif}
         {endif}
     {endif}
end. { Hyper_Text_Install }
