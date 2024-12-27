program Hyper_Text_Linker;
{
Auteur: Patrick Premartin
Date: (1.0) 28/12/1991. 29/12/1991. 30/12/1991. 02/01/1992. 06/01/1992.
            07/02/1992.
      (1.1) 30/07/1992. 03/08/1992.
Langage: Turbo Pascal 6.0
But: Utilisation et regroupement des fichiers .HTP dans les fichiers .HTD
}
uses
    crt,
    dos,
    olf_software,
    u_code_clavier,
    u_curseur,
    u_htd,
    u_htp,
    u_msg,
    u_m_zone,
    u_m_util;

const
     num_vers : string [3] = '1.1';
     dat_vers : string [10] = '08/03/1992';

var
   zone : p_m_zone;

function get_name (nom : string) : string;
var
   dir : dirstr;
   name : namestr;
   ext : extstr;
begin
     fsplit (nom, dir, name, ext);
     get_name := name;
end; { Get_Name }

var
   ht_nom : string;
   ht : p_hyper_text;
   menu1 : boolean;

procedure draw_menu (num_deb, num_act : word; ecran : p_ecran);
begin
  if (zone <> nil)
  then
    begin
      dispose (zone, done);
      zone := new (p_m_zone, init);
    end;
  {endif}
  gotoxy (1, 21);
  if menu1
  then
    begin
      zone^.add_zone (get_msg (1), 0, 7, 1, 21, 21, true, touche_f1);
      zone^.add_zone (get_msg (2), 7, 0, 22, 21, 23, true, touche_f5);
      zone^.add_zone (get_msg (3), 0, 7, 45, 21, 21, true, touche_f9);

      zone^.add_zone (get_msg (5), 7, 0, 1, 22, 21, true, touche_f2);
      zone^.add_zone (get_msg (6), 0, 7, 22, 22, 23, true, touche_f6);
      zone^.add_zone (get_msg (7), 7, 0, 45, 22, 21, true, touche_f10);

      zone^.add_zone (get_msg (9), 0, 7, 1, 23, 21, true, touche_f3);
      zone^.add_zone (get_msg (10), 7, 0, 22, 23, 23, true, touche_f7);
      zone^.add_zone (get_msg (11), 0, 7, 45, 23, 21, false, 'P');

      zone^.add_zone (get_msg (12), 7, 0, 1, 24, 21, true, touche_f4);
      zone^.add_zone (get_msg (13), 0, 7, 22, 24, 23, true, touche_f8);
      zone^.add_zone (get_msg (14), 7, 0, 45, 24, 21, false, 'N');
    end
  else
    begin
      zone^.add_zone (get_msg (1), 0, 7, 1, 21, 21, true, touche_f1);
      zone^.add_zone (get_msg (15), 7, 0, 22, 21, 23, true, touche_ctrl_f5);
      zone^.add_zone (get_msg (16), 0, 7, 45, 21, 21, true, touche_ctrl_f9);

      zone^.add_zone (get_msg (17), 7, 0, 1, 22, 21, true, touche_ctrl_f2);
      zone^.add_zone (get_msg (18), 0, 7, 22, 22, 23, true, touche_ctrl_f6);
      zone^.add_zone (get_msg (19), 7, 0, 45, 22, 21, false, 'S');

      zone^.add_zone (get_msg (20), 0, 7, 1, 23, 21, true, touche_ctrl_f3);
      zone^.add_zone (get_msg (21), 7, 0, 22, 23, 23, true, touche_ctrl_f7);
      zone^.add_zone (get_msg (22), 0, 7, 45, 23, 21, false, 'F');

      zone^.add_zone (get_msg (23), 7, 0, 1, 24, 21, true, touche_ctrl_f4);
      zone^.add_zone (get_msg (24), 0, 7, 22, 24, 23, true, touche_ctrl_f8);
      zone^.add_zone (get_msg (25), 7, 0, 45, 24, 21, false, 'L');
    end;
  {endif}
  zone^.add_zone (get_msg (4), 7, 0, 66, 21, 10, false, carac_nul);
  textattr := $07; gotoxy (76, 21); write (num_act : 5);
  zone^.add_zone (get_msg (8), 0, 7, 66, 22, 10, false, carac_nul);
  textattr := $70; gotoxy (76, 22); write (num_deb : 5);
  textattr := $07; gotoxy (66, 23); write (' HTD = ', get_name (ht_nom) : 8);
  textattr := $70; gotoxy (66, 24); write (' HTP = ', ecran^.txt^.fich_name:8);
  textattr := $07;
end; { Draw_Menu }

procedure draw_screen (num_deb, num_act : word; ecran : p_ecran);
begin
  ecran^.draw;
  draw_menu (num_deb, num_act, ecran);
end; { Draw_Screen }

procedure select_field (ecran : p_ecran);
var
   carac : char;
   x, y,
   i : integer;
   courant,
   prec,
   bouton : p_bouton;
   debut : boolean;
   ch : string;
begin
  bouton := new (p_bouton, init);
  curseur_pave;
  x := bouton^.x;
  y := bouton^.y;
  debut := false;
  if (ecran^.liste_bouton <> nil)
  then
      ecran^.liste_bouton^.unactive_all;
  {endif}
  repeat
    bouton^.active;
    if (x > max_col)
    then
      x := 1;
    {endif}
    if (x < 1)
    then
      x := max_col;
    {endif}
    if (y < 1)
    then
      y := max_lig;
    {endif}
    if (y > max_lig)
    then
      y := 1;
    {endif}
    gotoxy (x, y);
    carac := readkey;
    case carac of
      carac_nul :
        case readkey of
          touche_gauche :
            begin
              dec (x);
              if (x < 1)
              then
                begin
                  x := max_col;
                  dec (y);
                  if (y < 1)
                  then
                    y := max_lig;
                  {endif}
                end;
              {endif}
            end;
          touche_droite :
            begin
              inc (x);
              if (x > max_col)
              then
                begin
                  x := 1;
                  inc (y);
                  if (y > max_lig)
                  then
                    y := 1;
                  {endif}
                end;
              {endif}
            end;
          touche_haut :
            begin
              dec (y);
              if (y < 1)
              then
                y := max_lig;
              {endif}
            end;
          touche_bas :
            begin
              inc (y);
              if (y > max_lig)
              then
                y := 1;
              {endif}
            end;
          touche_page_up : y := 1;
          touche_page_dn : y := max_lig;
          touche_home : x := 1;
          touche_end :
            begin
              x := max_col;
              while ((x > 1) and (ecran^.txt^.ecran^.tab [y, x] = ' ')) do
                dec (x);
              {endwhile}
            end;
          touche_ctrl_gauche :
            begin
              dec (x);
              while ((x > 1) and (ecran^.txt^.ecran^.tab [y, x] = ' ')) do
                dec (x);
              {endwhile}
              while ((x > 1) and (ecran^.txt^.ecran^.tab [y, x] <> ' ')) do
                dec (x);
              {endwhile}
              if ((x > 1) and (ecran^.txt^.ecran^.tab [y, x] = ' '))
              then
                inc (x);
              {endif}
            end;
          touche_ctrl_droite :
            begin
              inc (x);
              while ((x < max_col) and (ecran^.txt^.ecran^.tab [y, x] <> ' ')) do
                inc (x);
              {endwhile}
              while ((x < max_col) and (ecran^.txt^.ecran^.tab [y, x] = ' ')) do
                inc (x);
              {endwhile}
            end;
        end;
      touche_return :
        if not debut
        then
          begin
            debut := true;
            bouton^.x := x;
            bouton^.y := y;
            carac := carac_nul;
          end;
        {endif}
      touche_tab : x := (x div 8) * 8 + 8;
    end;
    bouton^.unactive;
    if (debut)
    then
      if (((y = bouton^.y) and (x >= bouton^.x)) or (y > bouton^.y))
      then
        bouton^.l := succ ((y - bouton^.y) * max_col + x - bouton^.x)
      else
        bouton^.l := 0;
      {endif}
    {endif}
  until (carac in [touche_return, touche_escape]);
  if ((carac = touche_escape) or (bouton^.l = 0))
  then
    dispose (bouton, done)
  else
    begin
      with ecran^ do
        if (liste_bouton = nil)
        then
          liste_bouton := bouton
        else
          if ((liste_bouton^.y > bouton^.y) or ((liste_bouton^.y = bouton^.y)
             and (liste_bouton^.x > bouton^.x)))
          then
            begin
              bouton^.next := liste_bouton;
              liste_bouton := bouton;
            end
          else
            begin
              prec := liste_bouton;
              courant := prec^.next;
              while ((courant <> nil) and ((courant^.y < bouton^.y) or
                    ((courant^.y = bouton^.y) and (courant^.x < bouton^.x)))) do
                begin
                  prec := courant;
                  courant := courant^.next;
                end;
              {endwhile}
              bouton^.next := courant;
              prec^.next := bouton;
            end;
          {endif}
        {endif}
      {endwith}
      alert (get_msg (26), al_wait);
      ch := ecran^.txt^.fich_name;
      ch := get_name (get_fich_name (ch, 'HTP'));
      i := 1;
      while (i <= max_ecran) do
        if ((ht^.ht [i] <> nil) and (ht^.ht [i]^.txt^.fich_name = ch))
        then
          begin
            bouton^.effet.go_to := i;
            i := succ (max_ecran);
          end
        else
          inc (i);
        {endif}
      {endwhile}
      if (bouton^.effet.go_to < 1)
      then
        begin
          alert (get_msg (27), al_error);
          if (ecran^.liste_bouton = bouton)
          then
            ecran^.liste_bouton := bouton^.next
          else
            begin
              prec := ecran^.liste_bouton;
              while (prec^.next <> bouton) do
                prec := prec^.next;
              {endwhile}
              prec^.next := bouton^.next;
            end;
          {endif}
          bouton^.next := nil;
          dispose (bouton, done);
        end;
      {endif}
    end;
  {endif}
  curseur_on;
end; { Select_Field }

procedure unselect_field (ecran : p_ecran);
var
   carac : char;
   prec,
   bouton : p_bouton;
begin
  ecran^.draw;
  bouton := ecran^.liste_bouton;
  carac := ' ';
  while not ((carac in [touche_escape, touche_return]) or (bouton = nil)) do
    begin
      bouton^.active;
      carac := readkey;
      bouton^.unactive;
      case carac of
        carac_nul :
          case readkey of
            touche_home : bouton := ecran^.liste_bouton;
            touche_end :
              while (bouton^.next <> nil) do
                bouton := bouton^.next;
              {endwhile}
          end;
        touche_tab :
          begin
            bouton := bouton^.suivant;
            if (bouton = nil)
            then
              bouton := ecran^.liste_bouton;
            {endif}
          end;
      end;
    end;
  {endwhile}
  if ((carac = touche_return) and confirm (get_msg (28)))
  then
    begin
      if (ecran^.liste_bouton = bouton)
      then
        ecran^.liste_bouton := bouton^.next
      else
        begin
          prec := ecran^.liste_bouton;
          while (prec^.next <> bouton) do
            prec := prec^.next;
          {endwhile}
          prec^.next := bouton^.next;
        end;
      {endif}
      bouton^.next := nil;
      dispose (bouton, done);
    end;
  {endif}
end; { unselect_Field }

procedure del_bouton_pg (actuel : word);
var
   i : word;
   ecran : p_ecran;
   prec,
   bouton : p_bouton;
begin
  i := 1;
  while (i <= max_ecran) do
    begin
      if (ht^.ht [i] <> nil)
      then
        begin
          ecran := ht^.ht [i];
          bouton := ecran^.liste_bouton;
          while (bouton <> nil) do
            if (bouton^.effet.go_to = actuel)
            then
              begin
                if (ecran^.liste_bouton = bouton)
                then
                  ecran^.liste_bouton := bouton^.next
                else
                  begin
                    prec := ecran^.liste_bouton;
                    while (prec^.next <> bouton) do
                      prec := prec^.next;
                    {endwhile}
                    prec^.next := bouton^.next;
                  end;
                {endif}
                bouton^.next := nil;
                dispose (bouton, done);
                bouton := ecran^.liste_bouton;
              end
            else
              bouton := bouton^.next;
            {endif}
          {endwhile}
        end;
      {endif}
      inc (i);
    end;
  {endwhile}
end; { Del_Bouton_Pg }

procedure traitement;
var
   nom_fich : string;
   def_coul : byte;
   carac : char;
   i,
   actuel : word;
   load_other,
   code_nul,
   quit : boolean;
begin
  nom_fich := '';
  load_other := false;
  quit := false;
  with ht^ do
    begin
      if (debut = 0)
      then
        begin
          alert (get_msg (29), al_wait);
          nom_fich := '';
          nom_fich := get_fich_name (nom_fich, 'HTP');
          debut := 1;
          ht [1] := new (p_ecran, init);
          ht [1]^.txt := new (p_txt, init);
          ht [1]^.txt^.ecran := htp_load (nom_fich);
          ht [1]^.txt^.fich_name := get_name (nom_fich);
        end;
      {endif}
      actuel := debut;
      def_coul := ht [debut]^.couleur;
      draw_screen (debut, actuel, ht [actuel]);
      quit := false;
      repeat
        gotoxy (1, 25);
        write (get_msg (30));
        if (zone <> nil)
        then
          zone^.test_souris (code_nul, carac)
        else
          begin
            carac := readkey;
            code_nul := (carac = carac_nul);
            if (code_nul)
            then
              carac := readkey;
            {endif}
          end;
        {endif}
        if (code_nul)
        then
          case carac of
            touche_f1 :
              begin
                menu1 := not menu1;
                draw_menu (debut, actuel, ht [actuel]);
              end;
            touche_f2 :
              if confirm (get_msg (59))
              then
                save (ht_nom);
              {endif}
            touche_f3 :
              begin
                if confirm (get_msg (59))
                then
                  save (ht_nom);
                {endif}
                if confirm (get_msg (60))
                then
                  begin
                    nom_fich := get_fich_name (ht_nom, 'HTD');
                    if (nom_fich <> '')
                    then
                      begin
                        quit := true;
                        load_other := true;
                      end;
                    {endif}
                  end;
                {endif}
              end;
            touche_f4 :
              if confirm (get_msg (57))
              then
                begin
                  nom_fich := get_fich_name (nom_fich, 'HTP');
                  i := 1;
                  while ((i <= max_ecran) and (ht [i] <> nil)) do
                    inc (i);
                  {endwhile}
                  if (i > max_ecran)
                  then
                    alert ('Not enough space, please contact the coder...', al_error)
                  else
                    begin
                      ht [i] := new (p_ecran, init);
                      ht [i]^.couleur := def_coul;
                      ht [i]^.txt := new (p_txt, init);
                      ht [i]^.txt^.ecran := htp_load (nom_fich);
                      ht [i]^.txt^.fich_name := get_name (nom_fich);
                      actuel := i;
                    end;
                  {endif}
                  draw_screen (debut, actuel, ht [actuel]);
                end;
              {endif}
            touche_f5 :
              begin
                select_field (ht [actuel]);
                draw_screen (debut, actuel, ht [actuel]);
              end;
            touche_f6 :
              begin
                unselect_field (ht [actuel]);
                draw_screen (debut, actuel, ht [actuel]);
              end;
            touche_f7 :
              while confirm (get_msg (33)) do
                begin
                  i := succ (ht [actuel]^.couleur);
                  if (i > $07)
                  then
                    i := $01;
                  {endif}
                  ht [actuel]^.couleur := i;
                  draw_screen (debut, actuel, ht [actuel]);
                end;
              {endwhile}
            touche_f8 :
              if confirm (get_msg (34))
              then
                if (debut = actuel)
                then
                  alert (get_msg (35), al_error)
                else
                  begin
                    del_bouton_pg (actuel);
                    dispose (ht [actuel], done);
                    ht [actuel] := nil;
                    actuel := debut;
                    draw_screen (debut, actuel, ht [actuel]);
                  end;
                {endif}
              {endif}
            touche_f9 :
              if confirm (get_msg (36))
              then
                begin
                  run;
                  draw_screen (debut, actuel, ht [actuel]);
                end;
              {endif}
            touche_f10 : quit := confirm (get_msg (37));
            touche_ctrl_f2 :
              if confirm (get_msg (38))
              then
                begin
                  debut := actuel;
                  draw_menu (debut, actuel, ht [actuel]);
                end;
              {endif}
            touche_ctrl_f3 :
              if confirm (get_msg (39))
              then
                begin
                  i := 1;
                  while (i <= max_ecran) do
                    begin
                      if (ht [i] <> nil)
                      then
                        begin
                          nom_fich := ht [i]^.txt^.fich_name;
                          dispose (ht [i]^.txt^.ecran);
                          ht [i]^.txt^.ecran := htp_load (nom_fich);
                          ht [i]^.txt^.fich_name := get_name (nom_fich);
                        end;
                      {endif}
                      inc (i);
                    end;
                  {endwhile}
                  draw_screen (debut, actuel, ht [actuel]);
                end;
              {endif}
            touche_ctrl_f4 :
              if confirm (get_msg (40))
              then
                begin
                  nom_fich := ht [actuel]^.txt^.fich_name;
                  nom_fich := get_fich_name (nom_fich, 'HTP');
                  dispose (ht [actuel]^.txt^.ecran);
                  ht [actuel]^.txt^.ecran := htp_load (nom_fich);
                  ht [actuel]^.txt^.fich_name := get_name (nom_fich);
                  draw_screen (debut, actuel, ht [actuel]);
                end;
              {endif}
            touche_ctrl_f7 :
              if confirm (get_msg (41))
              then
                begin
                  i := ht [actuel]^.couleur;
                  while confirm (get_msg (33)) do
                    begin
                      i := succ (ht [actuel]^.couleur);
                      if (i > $07)
                      then
                        i := $01;
                      {endif}
                      ht [actuel]^.couleur := i;
                      draw_screen (debut, actuel, ht [actuel]);
                    end;
                  {endwhile}
                  def_coul := i;
                  i := 1;
                  while (i <= max_ecran) do
                    begin
                      if (ht [i] <> nil)
                      then
                        ht [i]^.couleur := def_coul;
                      {endif}
                      inc (i);
                    end;
                  {endwhile}
                end;
              {endif}
            touche_ctrl_f9 :
              begin
                alert (get_msg (42), al_wait);
                nom_fich := ht [actuel]^.txt^.fich_name;
                nom_fich := get_name (get_fich_name (nom_fich, 'HTP'));
                i := 1;
                while (i <= max_ecran) do
                  if ((ht [i] <> nil) and (ht [i]^.txt^.fich_name = nom_fich))
                  then
                    begin
                      actuel := i;
                      i := succ (max_ecran);
                    end
                  else
                    inc (i);
                  {endif}
                {endwhile}
                draw_screen (debut, actuel, ht [actuel]);
              end
          end
        else
          case upcase (carac) of
            'F' :
              begin
                i := 1;
                while ((i <= max_ecran) and (ht [i] = nil)) do
                  inc (i);
                {endwhile}
                if (i <= max_ecran)
                then
                  begin
                    actuel := i;
                    draw_screen (debut, actuel, ht [actuel]);
                  end;
                {endif}
              end;
            'L' :
              begin
                i := max_ecran;
                while ((i > 0) and (ht [i] = nil)) do
                  dec (i);
                {endwhile}
                if (i > 0)
                then
                  begin
                    actuel := i;
                    draw_screen (debut, actuel, ht [actuel]);
                  end;
                {endif}
              end;
            'N' :
              begin
                i := succ (actuel);
                while ((i <= max_ecran) and (ht [i] = nil)) do
                  inc (i);
                {endwhile}
                if (i <= max_ecran)
                then
                  begin
                    actuel := i;
                    draw_screen (debut, actuel, ht [actuel]);
                  end
                else
                  alert (get_msg (31), al_error);
                {endif}
              end;
            'P' :
              begin
                i := pred (actuel);
                while ((i > 0) and (ht [i] = nil)) do
                  dec (i);
                {endwhile}
                if (i > 0)
                then
                  begin
                    actuel := i;
                    draw_screen (debut, actuel, ht [actuel]);
                  end
                else
                  alert (get_msg (32), al_error);
                {endif}
              end;
            'S' :
              if ((debut > 0) and (debut <= max_ecran))
              then
                begin
                  actuel := debut;
                  draw_screen (debut, actuel, ht [actuel]);
                end;
              {endif}
            touche_alt_x,
            touche_escape : quit := confirm (get_msg (37));
          end;
        {endif}
      until quit;
    end;
  {endwith}
  if (load_other)
  then
    begin
      ht_nom := nom_fich;
      dispose (ht, done);
      ht := new (p_hyper_text, load (ht_nom));
      traitement;
    end;
  {endif}
end; { Traitement }

begin
  zone := new (p_m_zone, init);
  init_licence ('mkht');
  init_olf_message (mess_shareware);
  init_ligne_olf_software ('Hyper Texte Maker: Link '+num_vers, #155' Patrick Premartin '+dat_vers);
  ht_nom := '';
  menu1 := true;
  alert (get_msg (43), al_wait);
  ht_nom := get_fich_name (ht_nom, 'HTD');
  if not (ht_nom = '')
  then
    begin
      ht := new (p_hyper_text, load (ht_nom));
      if (ht <> nil)
      then
        begin
          traitement;
          dispose (ht, done);
        end;
      {endif}
    end;
  {endif}
  textattr := $07;
  clrscr;
  curseur_on;
  dispose (zone, done);
end.
