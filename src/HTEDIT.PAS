program Hyper_Text_Edit;
{
Auteur: Patrick Premartin
Date: (1.0) 27/12/1991. 30/12/1991. 31/12/1991.
      (1.1) 06/01/1992. 30/07/1992. 31/07/1992. 03/08/1992.
Langage: Turbo Pascal 6.0
But: Edition des ‚crans de 'Hyper Text Maker'.
}
uses
    crt,
    olf_software,
    u_curseur,
    u_code_clavier,
    u_chaine,
    u_htp,
    u_msg,
    u_m_util;

const
     num_vers = '1.1';
     dat_vers = '07/31/1992';

function get_line (page : p_page; y : byte) : string;
var
   res : string;
   i : byte;
begin
  for i := 1 to max_col do
    res [i] := page^.tab [y, i];
  {endfor}
  i := max_col;
  while ((i > 0) and (res [i] = ' ')) do
    dec (i);
  {endwhile}
  res [0] := chr (i);
  get_line := res;
end; { get_line }

procedure aff_ligne (page : p_page; y : byte);
var
   i : byte;
   ch : string;
begin
  gotoxy (1, y);
  ch := get_line (page, y);
  write (ch, trait (' ', max_col - length (ch)));
end; { aff_ligne }

procedure set_line (page : p_page; ch : string; y : byte);
var
   i : byte;
begin
  if (length (ch) > max_col)
  then
    for i := 1 to max_col do
      page^.tab [y, i] := ch [i]
    {endfor}
  else
    begin
      for i := 1 to length (ch) do
        page^.tab [y, i] := ch [i];
      {endfor}
      for i := succ (length (ch)) to max_col do
        page^.tab [y, i] := ' ';
      {endfor}
    end;
  {endif}
  aff_ligne (page, y);
end; { set_line }

procedure justifier_texte (page : p_page; var x, y : byte);
var
   ch,
   reste : string;
   i,
   j,
   k1,
   k : byte;
begin
  ch := get_line (page, y);
  if (pos (' ', ch) > 0)
  then
    begin
      { Compresser la ligne en cours. }
      i := 1;
      while ((i < max_col) and (ch [i] = ' ')) do
        inc (i);
      {endwhile}
      k1 := i;
      reste := copy (ch, i, succ (max_col - i));
      j := pos ('  ', reste);
      while (j <> 0) do
        begin
          delete (reste, j, 1);
          j := pos ('  ', reste);
        end;
      {endwhile}
      ch := copy (ch, 1, pred (i)) + reste;
      { Si la ligne compress‚e est plus petite que la ligne de l'‚cran, on
      continue sur la mˆme. Au contraire, si on est toujours … MAX_COL, on va
      rajouter des espaces dans la ligne et faire passer le morceau en trop sur
      la ligne suivante (en ‚crasement de ce qui y ‚tait). }
      if ((length (ch) < max_col) or ((length (ch) = max_col) and ((ch [max_col] = ' ') or (k1 = 0))))
      then
        begin
          set_line (page, ch, y);
          x := succ (length (ch));
        end
      else
        begin
          i := max_col;
          while ((i > 1) and (ch [i] <> ' ')) do
            dec (i);
          {endwhile}
          reste := copy (ch, succ (i), max_col - i);
          if (y = max_lig)
          then
            set_line (page, reste + get_line (page, 1), 1)
          else
            set_line (page, reste + get_line (page, succ (y)), succ (y));
          {endif}
          ch := copy (ch, 1, pred (i));
          k := k1;
          k1 := 0;
          j := i;
          while ((j <= max_col) and (k1 < 20)) do
            begin
              while ((ch [k] <> ' ') and (k1 < 20)) do
                if (k = max_col)
                then
                  begin
                    inc (k1);
                    k := 1;
                  end
                else
                  inc (k);
              {endwhile}
              insert (' ', ch, k);
              while ((ch [k] = ' ') and (k1 < 20)) do
                if (k = max_col)
                then
                  begin
                    inc (k1);
                    k := 1;
                  end
                else
                  inc (k);
              {endwhile}
              inc (j);
            end;
          {endwhile}
          set_line (page, ch, y);
          x := succ (length (reste));
          inc (y);
        end;
      {endif}
    end
  else
    inc (x);
  {endif}
end; { justifier_texte }

procedure aff_page (page : p_page);
var
   j : byte;
begin
  textcolor (lightgray);
  textbackground (black);
  clrscr;
  for j := 1 to max_lig do
    aff_ligne (page, j);
  {endfor}
  gotoxy (1, succ (max_lig));
  for j := 1 to 80 do
    write (#219);
  {endfor}
end; { Aff_Page }

procedure aff_help;
begin
  textcolor (white);
  textbackground (black);
  clrscr;
  writeln ('Hyper Text Maker: Edit');
  writeln;
  writeln ('(c) Patrick Premartin.');
  writeln;
  writeln;
  writeln (get_msg (45));
  writeln (get_msg (46));
  writeln;
  writeln (get_msg (47));
  writeln (get_msg (48));
  writeln (get_msg (49));
  writeln;
  writeln (get_msg (50));
  writeln (get_msg (51));
  writeln (get_msg (52));
  writeln (get_msg (53));
  writeln (get_msg (54));
  writeln (get_msg (55));
  alert ('', al_wait);
end; { Aff_Help }

procedure traitement (var nom_fich : string);
var
   page : p_page;
   carac : char;
   ox, oy,
   x, y : byte;
   quit : boolean;
   i, j : integer;

  procedure met_curseur (nx, ny : byte);
  begin
    textattr := $07;
    gotoxy (x, y);
    write (page^.tab [y, x]);
    textattr := $70;
    if (nx > max_col)
    then
      begin
        nx := 1;
        inc (ny);
      end;
    {endif}
    if (nx < 1)
    then
      begin
        nx := max_col;
        dec (ny);
      end;
    {endif}
    if (ny > max_lig)
    then
      ny := 1;
    {endif}
    if (ny < 1)
    then
      ny := max_lig;
    {endif}
    x := nx;
    y := ny;
    gotoxy (nx, ny);
    write (page^.tab [y, x]);
  end; { Met_Curseur }

  procedure met_page (x, y : byte; carac : char);
  begin
    page^.tab [y, x] := carac;
    textattr := $07;
    gotoxy (x, y);
    write (page^.tab [y, x]);
  end; { Met_Page }

begin
  page := htp_load (nom_fich);
  x := 1;
  y := 1;
  while (keypressed) do
        carac := readkey;
  {endwhile}
  quit := false;
  aff_page (page);
  repeat
    curseur_off;
    met_curseur (x, y);
    carac := readkey;
    if (carac = carac_nul)
    then
      case readkey of
        touche_f1 :
          begin
            aff_help;
            aff_page (page);
            x := 1;
            y := 1;
          end;
        touche_f2 :
          if confirm (get_msg (56))
          then
            htp_save (nom_fich, page);
          {endif}
        touche_f3 :
          if confirm (get_msg (57))
          then
            begin
              nom_fich := get_fich_name (nom_fich, 'HTP');
              freemem (page, sizeof (t_page));
              page := htp_load (nom_fich);
              x := 1;
              y := 1;
              aff_page (page);
            end;
          {endif}
        touche_f4 :
          begin
            for i := max_lig downto succ (y) do
              for j := 1 to max_col do
                page^.tab [i, j] := page^.tab [pred (i), j];
              {endfor}
            {endfor}
            for i := 1 to max_col do
              page^.tab [y, i] := ' ';
            {endfor}
            aff_page (page);
            met_curseur (x, y);
          end;
        touche_f5 :
          begin
            for i := y to pred (max_lig) do
              for j := 1 to max_col do
                page^.tab [i, j] := page^.tab [succ (i), j];
              {endfor}
            {endfor}
            for i := 1 to max_col do
              page^.tab [max_lig, i] := ' ';
            {endfor}
            aff_page (page);
            met_curseur (x, y);
          end;
        touche_alt_x,
        touche_f10 : quit := confirm (get_msg (37));
        touche_home :
          if (x > 1)
          then
            met_curseur (1, y)
          else
            begin
              ox := 1;
              while ((ox < max_col) and (page^.tab [y, ox] = ' ')) do
                inc (ox);
              {endwhile}
              met_curseur (ox, y);
            end;
          {endif}
        touche_end :
          if (x < max_col)
          then
            met_curseur (max_col, y)
          else
            begin
              ox := max_col;
              while ((ox > 1) and (page^.tab [y, ox] = ' ')) do
                dec (ox);
              {endwhile}
              met_curseur (ox, y);
            end;
          {endif}
        touche_page_up : met_curseur (x, 1);
        touche_page_dn : met_curseur (x, max_lig);
        touche_haut : met_curseur (x, pred (y));
        touche_bas : met_curseur (x, succ (y));
        touche_gauche : met_curseur (pred (x), y);
        touche_droite : met_curseur (succ (x), y);
        touche_ins :
          begin
            for i := max_col downto succ (x) do
              met_page (i, y, page^.tab [y, pred (i)]);
            {endfor}
            met_page (x, y, ' ');
            met_curseur (x, y);
          end;
        touche_del :
          begin
            for i := x to pred (max_col) do
              met_page (i, y, page^.tab [y, succ (i)]);
            {endfor}
            met_page (max_col, y, ' ');
            met_curseur (x, y);
          end;
        touche_ctrl_gauche :
          begin
            i := pred (x);
            j := y;
            while ((i > 1) and (page^.tab [j, i] = ' ')) do
              dec (i);
            {endwhile}
            while ((i > 1) and (page^.tab [j, i] <> ' ')) do
              dec (i);
            {endwhile}
            if ((i > 1) and (page^.tab [j, i] = ' '))
            then
              inc (i);
            {endif}
            met_curseur (i, j);
          end;
        touche_ctrl_droite :
          begin
            i := succ (x);
            j := y;
            while ((i < max_col) and (page^.tab [j, i] <> ' ')) do
              inc (i);
            {endwhile}
            while ((i < max_col) and (page^.tab [j, i] = ' ')) do
              inc (i);
            {endwhile}
            met_curseur (i, j);
          end;
      end
    else
      if (carac >= ' ')
      then
        begin
          met_page (x, y, carac);
          ox := x;
          oy := y;
          if (x = max_col)
          then
            justifier_texte (page, ox, oy)
          else
            inc (ox);
          {endif}
          met_curseur (ox, oy);
        end
      else
        case carac of
          touche_escape : quit := confirm (get_msg (37));
          touche_return : met_curseur (1, succ (y));
          touche_tab : met_curseur (((x + 8) div 8)*8, y);
          touche_backspace :
            if (x > 1)
            then
              begin
                for i := x to max_col do
                  met_page (pred (i), y, page^.tab [y, i]);
                {endfor}
                met_page (max_col, y, ' ');
                met_curseur (pred (x), y);
              end;
            {endif}
          end;
      {endif}
    {endif}
  until (quit);
  freemem (page, sizeof (t_page));
end; { Traitement }

var
   nom_fich : string;

begin
  init_licence ('mkht');
  init_olf_message (mess_shareware);
  init_ligne_olf_software ('Hyper Texte Maker: Edit '+num_vers, #155' Patrick Premartin '+dat_vers);
  nom_fich := '';
  alert (get_msg (58), al_nothing);
  nom_fich := get_fich_name (nom_fich, 'HTP');
  if not (nom_fich = '.HTP')
  then
    traitement (nom_fich);
  {endif}
  textattr := $07;
  clrscr;
  curseur_on;
end. { Hyper_Text_Edit }
