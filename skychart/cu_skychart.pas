unit cu_skychart;
{
Copyright (C) 2002 Patrick Chevalley

http://www.astrosurf.com/astropc
pch@freesurf.ch

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}
{
 Skychart computation component
}

interface

uses cu_plot, cu_catalog, u_constant, libcatalog, cu_planet,
     SysUtils, Classes, Math,
{$ifdef linux}
   QControls, QExtCtrls, QGraphics;
{$endif}
{$ifdef mswindows}
   Controls, ExtCtrls, Graphics;
{$endif}
type

Tskychart = class (TComponent)
   private
    Fplot: TSplot;
    Fcatalog : Tcatalog;
    Fplanet : Tplanet;
    Procedure DrawSatel(ipla:integer; ra,dec,ma,diam : double; hidesat, showhide : boolean);
   public
    cfgsc : conf_skychart;
    constructor Create(AOwner:Tcomponent); override;
    destructor  Destroy; override;
   published
    property plot: TSplot read Fplot;
    property catalog: Tcatalog read Fcatalog write Fcatalog;
    property planet: Tplanet read Fplanet write Fplanet;
    function Refresh : boolean;
    function InitCatalog : boolean;
    function InitTime : boolean;
    function InitChart : boolean;
    function InitColor : boolean;
    function GetFieldNum(fov:double):integer;
    function InitCoordinates : boolean;
    function InitObservatory : boolean;
    function DrawStars :boolean;
    function DrawVarStars :boolean;
    function DrawDblStars :boolean;
    function DrawNebulae :boolean;
    function DrawPlanet :boolean;
    function DrawOrbitPath:boolean;
    function DrawEqGrid :boolean;
    function DrawAzGrid :boolean;
    function DrawConstL :boolean;
    procedure GetCoord(x,y: integer; var ra,dec,a,h:double);
    procedure MoveChart(ns,ew:integer; movefactor:double);
    procedure MovetoXY(X,Y : integer);
    procedure MovetoRaDec(ra,dec:double);
    procedure Zoom(zoomfactor:double);
    procedure SetFOV(f:double);
    function PoleRot2000(ra,dec:double):double;
    procedure FormatCatRec(rec:Gcatrec; var desc:string);
    function FindatRaDec(ra,dec,dx: double):boolean;
    Procedure GetLabPos(ra,dec,r:double; w,h: integer; var x,y: integer);
end;


implementation

uses u_projection, u_util;

constructor Tskychart.Create(AOwner:Tcomponent);
begin
 inherited Create(AOwner);
 // set safe value
 cfgsc.JDChart:=jd2000;
 cfgsc.lastJDchart:=-1E25;
 cfgsc.racentre:=0;
 cfgsc.decentre:=0;
 cfgsc.fov:=1;
 cfgsc.theta:=0;
 cfgsc.projtype:='A';
 cfgsc.ProjPole:=Equat;
 cfgsc.FlipX:=1;
 cfgsc.FlipY:=1;
 cfgsc.WindowRatio:=1;
 cfgsc.BxGlb:=1;
 cfgsc.ByGlb:=1;
 cfgsc.AxGlb:=0;
 cfgsc.AyGlb:=0;
 cfgsc.xmin:=0;
 cfgsc.xmax:=100;
 cfgsc.ymin:=0;
 cfgsc.ymax:=100;
 cfgsc.RefractionOffset:=0;
 Fplot:=TSplot.Create(AOwner);
end;

destructor Tskychart.Destroy;
begin
 Fplot.free;
 inherited destroy;
end;

function Tskychart.Refresh :boolean;
begin
try
  chdir(appdir);
  InitObservatory;
  InitTime;
  Fplanet.ComputePlanet(cfgsc);
  InitColor;
  InitChart;
  InitCoordinates;
  InitCatalog;
  Fcatalog.OpenCat(cfgsc);
  DrawNebulae;
  DrawEqGrid;
  DrawAzGrid;
  DrawConstL;
  DrawStars;
  DrawDblStars;
  DrawVarStars;
  DrawOrbitPath;
  DrawPlanet;
  result:=true;
finally
  Fcatalog.CloseCat;
end;
end;

function Tskychart.InitCatalog:boolean;
var i:integer;
    mag:double;
  procedure InitStarC(cat:integer;defaultmag:double);
  { determine if the star catalog is active at this scale }
  begin
  if Fcatalog.cfgcat.starcatdef[cat-BaseStar] and
    (cfgsc.FieldNum>=Fcatalog.cfgcat.starcatfield[cat-BaseStar,1]) and
    (cfgsc.FieldNum<=Fcatalog.cfgcat.starcatfield[cat-BaseStar,2]) then begin
     Fcatalog.cfgcat.starcaton[cat-BaseStar]:=true;
     if Fcatalog.cfgshr.StarFilter then mag:=minvalue([defaultmag,Fcatalog.cfgcat.StarMagMax])
        else mag:=defaultmag;
     Fplot.cfgchart.min_ma:=maxvalue([Fplot.cfgchart.min_ma,mag]);
  end
     else Fcatalog.cfgcat.starcaton[cat-BaseStar]:=false;
  end;
  procedure InitVarC(cat:integer);
  { determine if the variable star catalog is active at this scale }
  begin
  if Fcatalog.cfgcat.varstarcatdef[cat-BaseVar] and
    (cfgsc.FieldNum>=Fcatalog.cfgcat.varstarcatfield[cat-BaseVar,1]) and
    (cfgsc.FieldNum<=Fcatalog.cfgcat.varstarcatfield[cat-BaseVar,2]) then
          Fcatalog.cfgcat.varstarcaton[cat-BaseVar]:=true
     else Fcatalog.cfgcat.varstarcaton[cat-BaseVar]:=false;
  end;
  procedure InitDblC(cat:integer);
  { determine if the double star catalog is active at this scale }
  begin
  if Fcatalog.cfgcat.dblstarcatdef[cat-BaseDbl] and
    (cfgsc.FieldNum>=Fcatalog.cfgcat.dblstarcatfield[cat-BaseDbl,1]) and
    (cfgsc.FieldNum<=Fcatalog.cfgcat.dblstarcatfield[cat-BaseDbl,2]) then
          Fcatalog.cfgcat.dblstarcaton[cat-BaseDbl]:=true
     else Fcatalog.cfgcat.dblstarcaton[cat-BaseDbl]:=false;
  end;
  procedure InitNebC(cat:integer);
  { determine if the nebulae catalog is active at this scale }
  begin
  if Fcatalog.cfgcat.nebcatdef[cat-BaseNeb] and
    (cfgsc.FieldNum>=Fcatalog.cfgcat.nebcatfield[cat-BaseNeb,1]) and
    (cfgsc.FieldNum<=Fcatalog.cfgcat.nebcatfield[cat-BaseNeb,2]) then
          Fcatalog.cfgcat.nebcaton[cat-BaseNeb]:=true
     else Fcatalog.cfgcat.nebcaton[cat-BaseNeb]:=false;
  end;
begin
if Fcatalog.cfgshr.AutoStarFilter then Fcatalog.cfgcat.StarMagMax:=round(10*(Fcatalog.cfgshr.AutoStarFilterMag+2.4*log10(intpower(pid2/cfgsc.fov,2))))/10
   else Fcatalog.cfgcat.StarMagMax:=Fcatalog.cfgshr.StarMagFilter[cfgsc.FieldNum];
Fcatalog.cfgcat.NebMagMax:=Fcatalog.cfgshr.NebMagFilter[cfgsc.FieldNum];
Fcatalog.cfgcat.NebSizeMin:=Fcatalog.cfgshr.NebSizeFilter[cfgsc.FieldNum];
Fplot.cfgchart.min_ma:=1;
{ activate the star catalog}
InitStarC(dsbase,5.5);
InitStarC(bsc,6.5);
InitStarC(sky2000,9.5);
InitStarC(tyc,11);
InitStarC(tyc2,12);
InitStarC(dstyc,12);
InitStarC(tic,12);
InitStarC(gsc,14.5);
InitStarC(gscf,14.5);
InitStarC(gscc,14.5);
InitStarC(dsgsc,14.5);
InitStarC(microcat,16);
InitStarC(usnoa,18);
{ activate the other catalog }
InitVarC(gcvs);
InitDblC(wds);
InitNebC(sac);
InitNebC(ngc);
InitNebC(lbn);
InitNebC(rc3);
InitNebC(pgc);
InitNebC(ocl);
InitNebC(gcm);
InitNebC(gpn);
Fcatalog.cfgcat.starcaton[gcstar-BaseStar]:=false;
Fcatalog.cfgcat.varstarcaton[gcvar-Basevar]:=false;
Fcatalog.cfgcat.dblstarcaton[gcdbl-Basedbl]:=false;
Fcatalog.cfgcat.nebcaton[gcneb-Baseneb]:=false;
//Fcatalog.cfgcat.starcaton[gclin-Baselin]:=false;
for i:=1 to Fcatalog.cfgcat.GCatNum do
  if Fcatalog.cfgcat.GCatLst[i-1].Actif and
     (cfgsc.FieldNum>=Fcatalog.cfgcat.GCatLst[i-1].min) and
     (cfgsc.FieldNum<=Fcatalog.cfgcat.GCatLst[i-1].max) then begin
         Fcatalog.cfgcat.GCatLst[i-1].CatOn:=true;
         case Fcatalog.cfgcat.GCatLst[i-1].cattype of
          rtstar: begin
                  Fcatalog.cfgcat.starcaton[gcstar-BaseStar]:=true;
                  if Fcatalog.cfgshr.StarFilter then mag:=minvalue([Fcatalog.cfgcat.GCatLst[i-1].magmax,Fcatalog.cfgcat.StarMagMax])
                                                else mag:=Fcatalog.cfgcat.GCatLst[i-1].magmax;
                  Fplot.cfgchart.min_ma:=maxvalue([Fplot.cfgchart.min_ma,mag]);
                  end;
          rtvar : Fcatalog.cfgcat.varstarcaton[gcvar-Basevar]:=true;
          rtdbl : Fcatalog.cfgcat.dblstarcaton[gcdbl-Basedbl]:=true;
          rtneb : Fcatalog.cfgcat.nebcaton[gcneb-Baseneb]:=true;
//          rtlin : Fcatalog.cfgcat.starcaton[gclin-Baselin]:=true;
         end;
  end else Fcatalog.cfgcat.GCatLst[i-1].CatOn:=false;
// give mag. limit result to other functions
cfgsc.StarFilter:=Fcatalog.cfgshr.StarFilter;
cfgsc.StarMagMax:=Fcatalog.cfgcat.StarMagMax;
result:=true;
end;

function Tskychart.InitTime:boolean;
begin
if cfgsc.UseSystemTime then begin
   SetCurrentTime(cfgsc);
   cfgsc.TimeZone:=GetTimezone
end else begin
   cfgsc.TimeZone:=cfgsc.ObsTZ;
end;
cfgsc.DT_UT:=DTminusUT(cfgsc.CurYear,cfgsc);
cfgsc.CurJD:=jd(cfgsc.CurYear,cfgsc.CurMonth,cfgsc.CurDay,cfgsc.CurTime-cfgsc.TimeZone+cfgsc.DT_UT);
cfgsc.jd0:=jd(cfgsc.CurYear,cfgsc.CurMonth,cfgsc.CurDay,0);
cfgsc.CurST:=Sidtim(cfgsc.jd0,cfgsc.CurTime-cfgsc.TimeZone,cfgsc.ObsLongitude);
if cfgsc.CurJD<>cfgsc.LastJD then begin // thing to do when the date change
   cfgsc.FindOk:=false;    // last search no longuer valid
end;
cfgsc.LastJD:=cfgsc.CurJD;
if (Fcatalog.cfgshr.Equinoxtype=2)or(cfgsc.projpole=altaz) then begin  // use equinox of the date
   cfgsc.JDChart:=cfgsc.CurJD;
   cfgsc.EquinoxName:='Date ';
end else begin
   cfgsc.JDChart:=Fcatalog.cfgshr.DefaultJDChart;
   cfgsc.EquinoxName:=fcatalog.cfgshr.EquinoxChart;
end;
if (cfgsc.lastJDchart<-1E20) then cfgsc.lastJDchart:=cfgsc.JDchart; // initial value
cfgsc.rap2000:=0;       // position of J2000 pole in current coordinates
cfgsc.dep2000:=pid2;
precession(jd2000,cfgsc.JDChart,cfgsc.rap2000,cfgsc.dep2000);
result:=true;
end;

function Tskychart.InitObservatory:boolean;
var u,p : double;
const ratio = 0.99664719;
      H0 = 6378140.0 ;
begin
   p:=deg2rad*cfgsc.ObsLatitude;
   u:=arctan(ratio*tan(p));
   cfgsc.ObsRoSinPhi:=ratio*sin(u)+(cfgsc.ObsAltitude/H0)*sin(p);
   cfgsc.ObsRoCosPhi:=cos(u)+(cfgsc.ObsAltitude/H0)*cos(p);
   cfgsc.ObsRefractionCor:=(cfgsc.ObsPressure/1010)*(283/(273+cfgsc.ObsTemperature));
   result:=true;
end;

function Tskychart.InitChart:boolean;
begin
// do not add more function here as this is also called at the chart create
cfgsc.xmin:=0;
cfgsc.ymin:=0;
cfgsc.xmax:=Fplot.cfgchart.width;
cfgsc.ymax:=Fplot.cfgchart.height;
ScaleWindow(cfgsc);
result:=true;
end;

function Tskychart.InitColor:boolean;
var i : integer;
begin
if Fplot.cfgplot.color[0]>Fplot.cfgplot.color[11] then begin
   Fplot.cfgplot.AutoSkyColor:=false;
   Fplot.cfgplot.StarPlot:=0;
   Fplot.cfgplot.NebPlot:=0;
end;
if Fplot.cfgplot.AutoSkyColor and (cfgsc.Projpole=AltAz) then begin
 if (cfgsc.fov>10*deg2rad) then begin
  if cfgsc.CurSunH>0 then i:=1
  else if cfgsc.CurSunH>-5*deg2rad then i:=2
  else if cfgsc.CurSunH>-11*deg2rad then i:=3
  else if cfgsc.CurSunH>-13*deg2rad then i:=4
  else if cfgsc.CurSunH>-15*deg2rad then i:=5
  else if cfgsc.CurSunH>-17*deg2rad then i:=6
  else i:=7;
 end else
  if cfgsc.CurSunH>0 then i:=5
  else if cfgsc.CurSunH>-5*deg2rad then i:=5
  else if cfgsc.CurSunH>-11*deg2rad then i:=6
  else if cfgsc.CurSunH>-13*deg2rad then i:=6
  else if cfgsc.CurSunH>-15*deg2rad then i:=7
  else if cfgsc.CurSunH>-17*deg2rad then i:=7
  else i:=7;
 if (i>=5)and(cfgsc.CurMoonH>0) then begin
    if (cfgsc.CurMoonIllum>0.1)and(cfgsc.CurMoonIllum<0.5) then i:=i-1;
    if (cfgsc.CurMoonIllum>=0.5) then i:=i-2;
    if i<5 then i:=5;
 end;
 Fplot.cfgplot.color[0]:=Fplot.cfgplot.SkyColor[i];
end else Fplot.cfgplot.color[0]:=Fplot.cfgplot.bgColor;
Fplot.cfgplot.backgroundcolor:=Fplot.cfgplot.color[0];
Fplot.init(Fplot.cfgchart.width,Fplot.cfgchart.height);
end;

function Tskychart.GetFieldNum(fov:double):integer;
var     i : integer;
begin
fov:=rad2deg*fov;
if fov>360 then fov:=360;
result:=MaxField;
for i:=0 to MaxField do if Fcatalog.cfgshr.FieldNum[i]>=fov then begin
       result:=i;
       break;
    end;
end;

function Tskychart.InitCoordinates:boolean;
var w,h,a,d,dist,v1,v2,v3,v4,v5,v6 : double;
begin
cfgsc.RefractionOffset:=0;
w := cfgsc.fov;
h := cfgsc.fov/cfgsc.WindowRatio;
w := maxvalue([w,h]);
// find the current field number and projection
cfgsc.FieldNum:=GetFieldNum(w);
cfgsc.projtype:=(cfgsc.projname[cfgsc.fieldnum]+'A')[1];
// is the chart to be centered on an object ?
 if cfgsc.TrackOn then begin
  case cfgsc.TrackType of
     1 : begin
         case cfgsc.Trackobj of
         1..9 : fplanet.Planet(cfgsc.TrackObj,cfgsc.CurJd,a,d,dist,v1,v2,v3,v4,v5);
         10   : fplanet.Sun(cfgsc.CurJd,a,d,dist,v1);
         11   : fplanet.Moon(cfgsc.CurJd,a,d,dist,v1,v2,v3,v4);
         32   : begin
                fplanet.Sun(cfgsc.CurJd,a,d,v1,v2);
                fplanet.Moon(cfgsc.CurJd,v1,v2,dist,v3,v4,v5,v6);
                a:=rmod(a+pi,pi2);
                d:=-d;
                end;
         end;
         if cfgsc.PlanetParalaxe then Paralaxe(cfgsc.CurST,dist,a,d,a,d,v1,cfgsc);
         cfgsc.racentre:=a;
         cfgsc.decentre:=d;
         end;
{     2 : begin
         InitComete(CometNum[FollowObj],buf);
         Comete(jdt,ar,de,dist,v1,v2,v3,v4,v5,v6,v7,v8);
         if PlanetParalaxe then Paralaxe(st0,dist,ar,de,ar,de,v1);
         arcentre:=ar;
         decentre:=de;
         end;
     3 : begin
         InitAsteroide(AsteroidNum[FollowObj],buf);
         Asteroide(jdt,ar,de,dist,v1,v2,v3,v4);
         if PlanetParalaxe then Paralaxe(st0,dist,ar,de,ar,de,v1);
         arcentre:=ar;
         decentre:=de;
         end;    }
     4 : begin
         if cfgsc.Projpole=AltAz then begin
           Hz2Eq(cfgsc.acentre,cfgsc.hcentre,cfgsc.racentre,cfgsc.decentre,cfgsc);
           cfgsc.racentre:=cfgsc.CurST-cfgsc.racentre;
           cfgsc.TrackOn:=false;
         end;
         end;
   end;
  end;
// normalize the coordinates
if (cfgsc.decentre>=(pid2-secarc)) then cfgsc.decentre:=pid2-secarc;
if (cfgsc.decentre<=(-pid2+secarc)) then cfgsc.decentre:=-pid2+secarc;
cfgsc.racentre:=rmod(cfgsc.racentre+pi2,pi2);
// apply precession if the epoch change from previous chart
if cfgsc.lastJDchart<>cfgsc.JDchart then
   precession(cfgsc.lastJDchart,cfgsc.JDchart,cfgsc.racentre,cfgsc.decentre);
cfgsc.lastJDchart:=cfgsc.JDchart;
// get alt/az center
Eq2Hz(cfgsc.CurST-cfgsc.racentre,cfgsc.decentre,cfgsc.acentre,cfgsc.hcentre,cfgsc) ;
// compute refraction error at the chart center
Hz2Eq(cfgsc.acentre,cfgsc.hcentre,a,d,cfgsc);
Eq2Hz(a,d,w,h,cfgsc) ;
cfgsc.RefractionOffset:=h-cfgsc.hcentre;
result:=true;
end;

function Tskychart.DrawStars :boolean;
var rec:GcatRec;
  x1,y1,cyear,dyear: Double;
  xx,yy,xxp,yyp: integer;
begin
fillchar(rec,sizeof(rec),0);
cyear:=cfgsc.CurYear+cfgsc.CurMonth/12;
dyear:=0;
try
if Fcatalog.OpenStar then
 while Fcatalog.readstar(rec) do begin
 if cfgsc.PMon or cfgsc.DrawPMon then begin
    if rec.star.valid[vsEpoch] then dyear:=cyear-rec.star.epoch
                               else dyear:=cyear-rec.options.Epoch;
 end;
 if cfgsc.PMon and rec.star.valid[vsPmra] and rec.star.valid[vsPmdec] then begin
    rec.ra:=rec.ra+(rec.star.pmra/cos(rec.dec))*dyear;
    rec.dec:=rec.dec+(rec.star.pmdec)*dyear;
 end;
 precession(rec.options.EquinoxJD,cfgsc.JDChart,rec.ra,rec.dec);
 projection(rec.ra,rec.dec,x1,y1,true,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 if (xx>cfgsc.Xmin) and (xx<cfgsc.Xmax) and (yy>cfgsc.Ymin) and (yy<cfgsc.Ymax) then begin
    Fplot.PlotStar(xx,yy,rec.star.magv,rec.star.b_v);
    if cfgsc.DrawPMon then begin
       rec.ra:=rec.ra+(rec.star.pmra/cos(rec.dec))*cfgsc.DrawPMyear;
       rec.dec:=rec.dec+(rec.star.pmdec)*cfgsc.DrawPMyear;
       projection(rec.ra,rec.dec,x1,y1,true,cfgsc) ;
       WindowXY(x1,y1,xxp,yyp,cfgsc);
       Fplot.PlotLine(xx,yy,xxp,yyp,Fplot.cfgplot.Color[15],1);
    end;
 end;
end;
result:=true;
finally
Fcatalog.CloseStar;
end;
end;

function Tskychart.DrawVarStars :boolean;
var rec:GcatRec;
  x1,y1: Double;
  xx,yy: integer;
begin
fillchar(rec,sizeof(rec),0);
try
if Fcatalog.OpenVarStar then
 while Fcatalog.readvarstar(rec) do begin
 precession(rec.options.EquinoxJD,cfgsc.JDChart,rec.ra,rec.dec);
 projection(rec.ra,rec.dec,x1,y1,true,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 if (xx>cfgsc.Xmin) and (xx<cfgsc.Xmax) and (yy>cfgsc.Ymin) and (yy<cfgsc.Ymax) then begin
    Fplot.PlotVarStar(xx,yy,rec.variable.magmax,rec.variable.magmin);
 end;
end;
result:=true;
finally
 Fcatalog.CloseVarStar;
end;
end;

function Tskychart.DrawDblStars :boolean;
var rec:GcatRec;
  x1,y1,x2,y2,rot: Double;
  xx,yy: integer;
begin
fillchar(rec,sizeof(rec),0);
try
if Fcatalog.OpenDblStar then
 while Fcatalog.readdblstar(rec) do begin
 precession(rec.options.EquinoxJD,cfgsc.JDChart,rec.ra,rec.dec);
 projection(rec.ra,rec.dec,x1,y1,true,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 if (xx>cfgsc.Xmin) and (xx<cfgsc.Xmax) and (yy>cfgsc.Ymin) and (yy<cfgsc.Ymax) then begin
    projection(rec.ra,rec.dec+0.001,x2,y2,false,cfgsc) ;
    rot:=arctan2((x1-x2),(y1-y2));
    if (not rec.double.valid[vdPA])or(rec.double.pa=-999) then rec.double.pa:=0
        else rec.double.pa:=rec.double.pa-rad2deg*PoleRot2000(rec.ra,rec.dec);
    rec.double.pa:=rec.double.pa*cfgsc.FlipX;
    if cfgsc.FlipY<0 then rec.double.pa:=180-rec.double.pa;
    if cfgsc.FlipY<0 then rot:=rot-pi;
    rec.double.pa:=DegToRad(rec.double.pa)-rot;
    Fplot.PlotDblStar(xx,yy,rec.double.mag1,rec.double.sep,rec.double.pa,0);
 end;
end;
result:=true;
finally
  Fcatalog.CloseDblStar;
end;
end;

function Tskychart.PoleRot2000(ra,dec:double):double;
var  x1,y1: Double;
begin
if cfgsc.JDChart=jd2000 then result:=0
else begin
  Proj2(cfgsc.rap2000,cfgsc.dep2000,ra,dec,x1,y1,cfgsc);
  result:=arctan2(x1,y1);
end;
end;

function Tskychart.DrawNebulae :boolean;
var rec:GcatRec;
  x1,y1,x2,y2,rot: Double;
  xx,yy: integer;
begin
fillchar(rec,sizeof(rec),0);
try
if Fcatalog.OpenNeb then
 while Fcatalog.readneb(rec) do begin
 precession(rec.options.EquinoxJD,cfgsc.JDChart,rec.ra,rec.dec);
 projection(rec.ra,rec.dec,x1,y1,true,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 if (xx>cfgsc.Xmin) and (xx<cfgsc.Xmax) and (yy>cfgsc.Ymin) and (yy<cfgsc.Ymax) then begin
  if not rec.neb.valid[vnNebtype] then rec.neb.nebtype:=rec.options.ObjType;
  if not rec.neb.valid[vnNebunit] then rec.neb.nebunit:=rec.options.Units;
  if rec.neb.nebtype=1 then begin
      projection(rec.ra,rec.dec+0.001,x2,y2,false,cfgsc) ;
      rot:=arctan2((x1-x2),(y1-y2));
      if (not rec.neb.valid[vnPA])or(rec.neb.pa=-999) then rec.neb.pa:=90
          else rec.neb.pa:=rec.neb.pa-rad2deg*PoleRot2000(rec.ra,rec.dec);
      rec.neb.pa:=rec.neb.pa*cfgsc.FlipX;
      if cfgsc.FlipY<0 then rec.neb.pa:=180-rec.neb.pa;
      if cfgsc.FlipY<0 then rot:=rot-pi;
      rec.neb.pa:=DegToRad(rec.neb.pa)-rot;
      Fplot.PlotGalaxie(xx,yy,rec.neb.dim1,rec.neb.dim2,rec.neb.pa,0,100,100,rec.neb.mag,rec.neb.sbr,abs(cfgsc.BxGlb)*deg2rad/rec.neb.nebunit);
   end else
      Fplot.PlotNebula(xx,yy,rec.neb.dim1,rec.neb.mag,rec.neb.sbr,abs(cfgsc.BxGlb)*deg2rad/rec.neb.nebunit,rec.neb.nebtype);
 end;
end;
result:=true;
finally
 Fcatalog.CloseDblStar;
end;
end;

function Tskychart.DrawPlanet :boolean;
var
  x1,y1,x2,y2,pixscale,ra,dec,jdt,diam,magn,phase,fov,illum,pa,rot,r1,r2,be,dist: Double;
  xx,yy,xxp,yyp,i,j,n,ipla: integer;
  draworder : array[1..11] of integer;
begin
if not cfgsc.ShowPlanet then exit;
fov:=rad2deg*cfgsc.fov;
pixscale:=abs(cfgsc.BxGlb)*deg2rad/3600;
for j:=0 to cfgsc.SimNb-1 do begin
  draworder[1]:=1;
  for n:=2 to 11 do begin
    if cfgsc.Planetlst[j,n,6]<cfgsc.Planetlst[j,draworder[n-1],6] then
       draworder[n]:=n
    else begin
       i:=n;
       repeat
         i:=i-1;
         draworder[i+1]:=draworder[i];
       until (i=1)or(cfgsc.Planetlst[j,n,6]<=cfgsc.Planetlst[j,draworder[i-1],6]);
       draworder[i]:=n;
    end;
  end;
  for n:=1 to 11 do begin
    ipla:=draworder[n];
    if (j>0) and (not cfgsc.SimObject[ipla]) then continue;
    if ipla=3 then continue;
    ra:=cfgsc.Planetlst[j,ipla,1];
    dec:=cfgsc.Planetlst[j,ipla,2];
    jdt:=cfgsc.Planetlst[j,ipla,3];
    diam:=cfgsc.Planetlst[j,ipla,4];
    magn:=cfgsc.Planetlst[j,ipla,5];
    phase:=cfgsc.Planetlst[j,ipla,7];
    projection(ra,dec,x1,y1,true,cfgsc) ;
    WindowXY(x1,y1,xx,yy,cfgsc);
    projection(ra,dec+0.001,x2,y2,false,cfgsc) ;
    rot:=arctan2((x1-x2),(y1-y2));
    if cfgsc.FlipY<0 then rot:=rot-pi;
    case ipla of
    4 :  begin
         if (fov<=1.5) and (cfgsc.Planetlst[j,29,6]<90) then for i:=1 to 2 do DrawSatel(i+28,cfgsc.Planetlst[j,i+28,1],cfgsc.Planetlst[j,i+28,2],cfgsc.Planetlst[j,i+28,5],cfgsc.Planetlst[j,i+28,4],cfgsc.Planetlst[j,i+28,6]>1.0,true);
         if (xx>-cfgsc.Xmax) and (xx<2*cfgsc.Xmax) and (yy>-cfgsc.Ymax) and (yy<2*cfgsc.Ymax) then
            Fplot.PlotPlanet(xx,yy,ipla,pixscale,jdt,diam,magn,phase,0,0,0,0,0,0,0);
         if (fov<=1.5) and (cfgsc.Planetlst[j,29,6]<90) then for i:=1 to 2 do DrawSatel(i+28,cfgsc.Planetlst[j,i+28,1],cfgsc.Planetlst[j,i+28,2],cfgsc.Planetlst[j,i+28,5],cfgsc.Planetlst[j,i+28,4],cfgsc.Planetlst[j,i+28,6]>1.0,false);
         end;
    5 :  begin
         if (fov<=1.5) and (cfgsc.Planetlst[j,12,6]<90) then for i:=1 to 4 do DrawSatel(i+11,cfgsc.Planetlst[j,i+11,1],cfgsc.Planetlst[j,i+11,2],cfgsc.Planetlst[j,i+11,5],cfgsc.Planetlst[j,i+11,4],cfgsc.Planetlst[j,i+11,6]>1.0,true);
         if (xx>-cfgsc.Xmax) and (xx<2*cfgsc.Xmax) and (yy>-cfgsc.Ymax) and (yy<2*cfgsc.Ymax) then
            Fplot.PlotPlanet(xx,yy,ipla,pixscale,jdt,diam,magn,phase,0,0,0,0,0,0,0);
         if (fov<=1.5) and (cfgsc.Planetlst[j,12,6]<90) then for i:=1 to 4 do DrawSatel(i+11,cfgsc.Planetlst[j,i+11,1],cfgsc.Planetlst[j,i+11,2],cfgsc.Planetlst[j,i+11,5],cfgsc.Planetlst[j,i+11,4],cfgsc.Planetlst[j,i+11,6]>1.0,false);
         end;
    6 :  begin
         if (fov<=1.5) and (cfgsc.Planetlst[j,16,6]<90) then for i:=1 to 8 do DrawSatel(i+15,cfgsc.Planetlst[j,i+15,1],cfgsc.Planetlst[j,i+15,2],cfgsc.Planetlst[j,i+15,5],cfgsc.Planetlst[j,i+15,4],cfgsc.Planetlst[j,i+15,6]>1.0,true);
         if (xx>-cfgsc.Xmax) and (xx<2*cfgsc.Xmax) and (yy>-cfgsc.Ymax) and (yy<2*cfgsc.Ymax) then begin
            pa:=cfgsc.Planetlst[j,31,1]*cfgsc.FlipX;
            r1:=cfgsc.Planetlst[j,31,2];
            r2:=cfgsc.Planetlst[j,31,3];
            be:=cfgsc.Planetlst[j,31,4];
            if cfgsc.FlipY<0 then pa:=180-pa;
            Fplot.PlotPlanet(xx,yy,ipla,pixscale,jdt,diam,magn,phase,0,pa,rot,r1,r2,be,0);
         end;
         if (fov<=1.5) and (cfgsc.Planetlst[j,16,6]<90) then for i:=1 to 8 do DrawSatel(i+15,cfgsc.Planetlst[j,i+15,1],cfgsc.Planetlst[j,i+15,2],cfgsc.Planetlst[j,i+15,5],cfgsc.Planetlst[j,i+15,4],cfgsc.Planetlst[j,i+15,6]>1.0,false);
         end;
    7 :  begin
         if (fov<=1.5) and (cfgsc.Planetlst[j,24,6]<90) then for i:=1 to 5 do DrawSatel(i+23,cfgsc.Planetlst[j,i+23,1],cfgsc.Planetlst[j,i+23,2],cfgsc.Planetlst[j,i+23,5],cfgsc.Planetlst[j,i+23,4],cfgsc.Planetlst[j,i+23,6]>1.0,true);
         if (xx>-cfgsc.Xmax) and (xx<2*cfgsc.Xmax) and (yy>-cfgsc.Ymax) and (yy<2*cfgsc.Ymax) then
            Fplot.PlotPlanet(xx,yy,ipla,pixscale,jdt,diam,magn,phase,0,0,0,0,0,0,0);
         if (fov<=1.5) and (cfgsc.Planetlst[j,24,6]<90) then for i:=1 to 5 do DrawSatel(i+23,cfgsc.Planetlst[j,i+23,1],cfgsc.Planetlst[j,i+23,2],cfgsc.Planetlst[j,i+23,5],cfgsc.Planetlst[j,i+23,4],cfgsc.Planetlst[j,i+23,6]>1.0,false);
         end;
    11 : begin
         if (xx>-cfgsc.Xmax) and (xx<2*cfgsc.Xmax) and (yy>-cfgsc.Ymax) and (yy<2*cfgsc.Ymax) then begin
            illum:=magn;
            magn:=-10;  // better to alway show a bright dot for the Moon
            dist:=cfgsc.Planetlst[j,ipla,6];
            fplanet.MoonIncl(ra,dec,cfgsc.PlanetLst[j,10,1],cfgsc.PlanetLst[j,10,2],pa);
            pa:=pa*cfgsc.FlipX;
            if cfgsc.FlipY<0 then pa:=180-pa;
            Fplot.PlotPlanet(xx,yy,ipla,pixscale,jdt,diam,magn,phase,illum,pa,rot,0,0,0,dist);
         end;
         end;
    else begin
         if (xx>-cfgsc.Xmax) and (xx<2*cfgsc.Xmax) and (yy>-cfgsc.Ymax) and (yy<2*cfgsc.Ymax) then
            Fplot.PlotPlanet(xx,yy,ipla,pixscale,jdt,diam,magn,phase,0,0,0,0,0,0,0);
         end;
    end;
//  end;
  //if ShowEarthUmbra then DrawEarthUmbra(cfgsc.Planetlst[j,32,1],cfgsc.Planetlst[j,32,2],cfgsc.Planetlst[j,32,3],cfgsc.Planetlst[j,32,4],cfgsc.Planetlst[j,32,5],onprinter,out);
  end;
end;
result:=true;
end;

Procedure Tskychart.DrawSatel(ipla:integer; ra,dec,ma,diam : double; hidesat, showhide : boolean);
var
  x1,y1 : double;
  xx,yy : Integer;
begin
projection(ra,dec,x1,y1,true,cfgsc) ;
WindowXY(x1,y1,xx,yy,cfgsc);
Fplot.PlotSatel(xx,yy,ipla,abs(cfgsc.BxGlb)*deg2rad/3600,ma,diam,hidesat,showhide);
end;

function Tskychart.DrawOrbitPath:boolean;
var i,j,xx,yy,xp,yp,color : integer;
    x1,y1 : double;
begin
Color:=Fplot.cfgplot.Color[14];
xp:=0;yp:=0;
if cfgsc.ShowPlanet then for i:=1 to 11 do
  if (i<>3)and(cfgsc.SimObject[i]) then for j:=0 to cfgsc.SimNb-1 do begin
    projection(cfgsc.Planetlst[j,i,1],cfgsc.Planetlst[j,i,2],x1,y1,true,cfgsc) ;
    windowxy(x1,y1,xx,yy,cfgsc);
    if (j<>0)and((xx>-2*cfgsc.xmax)and(yy>-2*cfgsc.ymax)and(xx<3*cfgsc.xmax)and(yy<3*cfgsc.ymax))
       and ((xp>-2*cfgsc.xmax)and(yp>-2*cfgsc.ymax)and(xp<3*cfgsc.xmax)and(yp<3*cfgsc.ymax)) then 
       Fplot.PlotLine(xp,yp,xx,yy,color,1);
    xp:=xx;
    yp:=yy;
end;
{for i:=1 to CometNb do
  for j:=0 to SimNb-1 do begin
    projection(CometPlst[j,i,1]*15,CometPlst[j,i,2],x1,y1,true) ;
    windowxy(x1,y1,xx,yy);
    if (j=0)or((xx<-xmax)or(yy<-ymax)or(xx>2*xmax)or(yy>2*ymax)) then Moveto(xx,yy)
       else Lineto(xx,yy);
  end;
for i:=1 to AsteroidNb do
  for j:=0 to SimNb-1 do begin
    projection(AsteroidPlst[j,i,1]*15,AsteroidPlst[j,i,2],x1,y1,true) ;
    windowxy(x1,y1,xx,yy);
    if (j=0)or((xx<-xmax)or(yy<-ymax)or(xx>2*xmax)or(yy>2*ymax)) then Moveto(xx,yy)
       else Lineto(xx,yy);
  end;}
result:=true;  
end;

procedure Tskychart.GetCoord(x,y: integer; var ra,dec,a,h:double);
begin
getadxy(x,y,ra,dec,cfgsc);
GetAHxy(X,Y,a,h,cfgsc);
if Fcatalog.cfgshr.AzNorth then a:=rmod(a+pi,pi2);
end;

procedure Tskychart.MoveChart(ns,ew:integer; movefactor:double);
begin
 if cfgsc.Projpole=AltAz then begin
    cfgsc.acentre:=rmod(cfgsc.acentre-ew*cfgsc.fov/movefactor/cos(cfgsc.hcentre)+pi2,pi2);
    cfgsc.hcentre:=cfgsc.hcentre+ns*cfgsc.fov/movefactor/cfgsc.windowratio;
    if cfgsc.hcentre>pid2 then cfgsc.hcentre:=pi-cfgsc.hcentre;
    Hz2Eq(cfgsc.acentre,cfgsc.hcentre,cfgsc.racentre,cfgsc.decentre,cfgsc);
    cfgsc.racentre:=cfgsc.CurST-cfgsc.racentre;
 end
 else begin
    cfgsc.racentre:=rmod(cfgsc.racentre+ew*cfgsc.fov/movefactor/cos(cfgsc.decentre)+pi2,pi2);
    cfgsc.decentre:=cfgsc.decentre+ns*cfgsc.fov/movefactor/cfgsc.windowratio;
    if cfgsc.decentre>pid2 then cfgsc.decentre:=pi-cfgsc.decentre;
end;
end;

procedure Tskychart.MovetoXY(X,Y : integer);
begin
   GetADxy(X,Y,cfgsc.racentre,cfgsc.decentre,cfgsc);
   cfgsc.racentre:=rmod(cfgsc.racentre+pi2,pi2);
end;

procedure Tskychart.MovetoRaDec(ra,dec:double);
begin
   cfgsc.racentre:=rmod(ra+pi2,pi2);
   cfgsc.decentre:=dec;
end;

procedure Tskychart.Zoom(zoomfactor:double);
begin
 SetFOV(cfgsc.fov/zoomfactor);
end;

procedure Tskychart.SetFOV(f:double);
begin
 cfgsc.fov := f;
 if cfgsc.fov<FovMin then cfgsc.fov:=FovMin;
 if cfgsc.fov>FovMax then cfgsc.fov:=FovMax;
end;

Procedure Tskychart.FormatCatRec(rec:Gcatrec; var desc:string);
var txt: string;
    i : integer;
const b=' ';
      b5='     ';
      dp = ':';
begin
 cfgsc.FindRA:=rec.ra;
 cfgsc.FindDec:=rec.dec;
 cfgsc.FindSize:=0;
 desc:= ARpToStr(rmod(rad2deg*rec.ra/15+24,24))+b+DEpToStr(rad2deg*rec.dec);
 case rec.options.rectype of
 rtStar: begin   // stars
         if rec.star.valid[vsId] then txt:=rec.star.id else txt:='';
         if trim(txt)='' then catalog.GetAltName(rec,txt);
         txt:=rec.options.ShortName+b+txt;
         cfgsc.FindName:=txt;
         Desc:=Desc+'   * '+txt;
         if rec.star.magv<90 then str(rec.star.magv:5:2,txt) else txt:=b5;
         Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsMagv])+dp+txt;
         if rec.star.valid[vsB_v] then begin
            if (rec.star.b_v<90) then str(rec.star.b_v:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsB_v])+dp+txt;
         end;
         if rec.star.valid[vsMagb] then begin
            if (rec.star.magb<90) then str(rec.star.magb:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsMagb])+dp+txt;
         end;
         if rec.star.valid[vsMagr] then begin
            if (rec.star.magr<90) then str(rec.star.magr:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsMagr])+dp+txt;
         end;
         if rec.star.valid[vsSp] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsSp])+dp+rec.star.sp;
         if rec.star.valid[vsPmra] then begin
            str(rad2deg*3600*rec.star.pmra:6:3,txt);
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsPmra])+dp+txt;
         end;
         if rec.star.valid[vsPmdec] then begin
            str(rad2deg*3600*rec.star.pmdec:6:3,txt);
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsPmdec])+dp+txt;
         end;
         if rec.star.valid[vsEpoch] then begin
            str(rec.star.epoch:8:2,txt);
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsEpoch])+dp+txt;
         end;
         if rec.star.valid[vsPx] then begin
            str(rec.star.px:6:4,txt);
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsPx])+dp+txt;
            if rec.star.px>0 then begin
               str(3.2616/rec.star.px:5:1,txt);
               Desc:=Desc+' Dist:'+txt+b+'ly';
            end;
         end;
         if rec.star.valid[vsComment] then
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vsComment])+dp+b+rec.star.comment;
         end;
 rtVar : begin   // variables stars
         if rec.variable.valid[vvId] then txt:=rec.variable.id else txt:='';
         if trim(txt)='' then catalog.GetAltName(rec,txt);
         txt:=rec.options.ShortName+b+txt;
         cfgsc.FindName:=txt;
         Desc:=Desc+'  V* '+txt;
         if rec.variable.valid[vvVartype] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvVartype])+dp+rec.variable.vartype;
         if rec.variable.valid[vvMagcode] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvMagcode])+dp+rec.variable.magcode;
         if rec.variable.valid[vvMagmax] then begin
            if (rec.variable.magmax<90) then str(rec.variable.magmax:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvMagmax])+dp+txt;
         end;
         if rec.variable.valid[vvMagmin] then begin
            if (rec.variable.magmin<90) then str(rec.variable.magmin:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvMagmin])+dp+txt;
         end;
         if rec.variable.valid[vvPeriod] then begin
            str(rec.variable.period:16:10,txt);
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvPeriod])+dp+txt;
         end;
         if rec.variable.valid[vvMaxepoch] then begin
            str(rec.variable.Maxepoch:16:10,txt);
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvMaxepoch])+dp+txt;
         end;
         if rec.variable.valid[vvRisetime] then begin
            str(rec.variable.risetime:5:2,txt);
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvRisetime])+dp+txt;
         end;
         if rec.variable.valid[vvSp] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvSp])+dp+rec.variable.sp;
         if rec.variable.valid[vvComment] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vvComment])+dp+rec.variable.comment;
         end;
 rtDbl : begin   // doubles stars
         if rec.double.valid[vdId] then txt:=rec.double.id else txt:='';
         if trim(txt)='' then catalog.GetAltName(rec,txt);
         txt:=rec.options.ShortName+b+txt;
         cfgsc.FindName:=txt;
         Desc:=Desc+'  D* '+txt;
         if rec.double.valid[vdCompname] then Desc:=Desc+b+rec.double.compname;
         if rec.double.valid[vdMag1] then begin
            if (rec.double.mag1<90) then str(rec.double.mag1:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vdMag1])+dp+txt;
         end;
         if rec.double.valid[vdMag2] then begin
            if (rec.double.mag2<90) then str(rec.double.mag2:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vdMag2])+dp+txt;
         end;
         if rec.double.valid[vdSep] then begin
            if (rec.double.sep>0) then str(rec.double.sep:5:1,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vdSep])+dp+txt;
            cfgsc.FindSize:=rec.double.sep*secarc;
         end;
         if rec.double.valid[vdPa] then begin
            if (rec.double.pa>0) then str(round(rec.double.pa-rad2deg*PoleRot2000(rec.ra,rec.dec)):3,txt) else txt:='   ';
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vdPa])+dp+txt;
         end;
         if rec.double.valid[vdEpoch] then begin
            str(rec.double.epoch:4:2,txt);
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vdEpoch])+dp+txt;
         end;
         if rec.double.valid[vdSp1] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vdSp1])+dp+' 1 '+rec.double.sp1;
         if rec.double.valid[vdSp2] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vdSp2])+dp+' 2 '+rec.double.sp2;
         if rec.double.valid[vdComment] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vdComment])+dp+rec.double.comment;
         end;
 rtNeb : begin   // nebulae
         if rec.neb.valid[vnId] then txt:=rec.neb.id else txt:='';
         if trim(txt)='' then catalog.GetAltName(rec,txt);
         cfgsc.FindName:=txt;
         if rec.neb.valid[vnNebtype] then i:=rec.neb.nebtype
                                        else i:=rec.options.ObjType;
         Desc:=Desc+' '+nebtype[i+2]+' '+txt;
         if rec.neb.valid[vnMag] then begin
            if (rec.neb.mag<90) then str(rec.neb.mag:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vnMag])+dp+txt;
         end;
         if rec.neb.valid[vnSbr] then begin
            if (rec.neb.sbr<90) then str(rec.neb.sbr:5:2,txt) else txt:=b5;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vnSbr])+dp+txt;
         end;
         if rec.options.LogSize=0 then begin
            if rec.neb.valid[vnDim1] then cfgsc.FindSize:=rec.neb.dim1
                                     else cfgsc.FindSize:=rec.options.Size;
            str(cfgsc.FindSize:5:1,txt);
            Desc:=Desc+b+'Dim'+dp+txt;
            if rec.neb.valid[vnDim2] and (rec.neb.dim2>0) then str(rec.neb.dim2:5:1,txt);
            Desc:=Desc+' x'+txt+b;
            if rec.neb.valid[vnNebunit] then i:=rec.neb.nebunit
                                        else i:=rec.options.Units;
            if i=0 then i:=1;                            
            cfgsc.FindSize:=deg2rad*cfgsc.FindSize/i;
            case i of
            1    : Desc:=Desc+ldeg;
            60   : Desc:=Desc+lmin;
            3600 : Desc:=Desc+lsec;
            end;
         end else begin
            if rec.neb.valid[vnDim1] then str(rec.neb.dim1:5:1,txt)
                                     else txt:=b5;
            Desc:=Desc+' Flux:'+txt+b;
         end;
         if rec.neb.valid[vnPa] then begin
            if (rec.neb.pa>0) then str(rec.neb.pa-rad2deg*PoleRot2000(rec.ra,rec.dec):3:0,txt) else txt:='   ';
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vnPa])+dp+txt;
         end;
         if rec.neb.valid[vnRv] then begin
            str(rec.neb.rv:6:0,txt) ;
            Desc:=Desc+b+trim(rec.options.flabel[lOffset+vnRv])+dp+txt;
         end;
         if rec.neb.valid[vnMorph] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vnMorph])+dp+rec.neb.morph;
         if rec.neb.valid[vnComment] then Desc:=Desc+b+trim(rec.options.flabel[lOffset+vnComment])+dp+rec.neb.comment;
         end;
 end;
 for i:=1 to 10 do begin
   if rec.vstr[i] then Desc:=Desc+b+trim(rec.options.flabel[15+i])+dp+rec.str[i];
 end;
 for i:=1 to 10 do begin
   if rec.vnum[i] then Desc:=Desc+b+trim(rec.options.flabel[25+i])+dp+formatfloat('0.0####',rec.num[i]);
 end;
 cfgsc.FindDesc:=Desc;
 cfgsc.FindNote:='';
end;

function Tskychart.FindatRaDec(ra,dec,dx: double):boolean;
var x1,x2,y1,y2:double;
    rec: Gcatrec;
     desc,n,m,d: string;
begin
x1 := NormRA(ra-dx/cos(dec));
x2 := NormRA(ra+dx/cos(dec));
y1 := maxvalue([-pid2,dec-dx]);
y2 := minvalue([pid2,dec+dx]);
desc:='';
// search catalog object
result:=fcatalog.Findobj(x1,y1,x2,y2,false,cfgsc,rec);
if result then begin
   FormatCatRec(rec,desc);
end else begin
// search solar system object
   result:=fplanet.findplanet(x1,y1,x2,y2,false,cfgsc,n,m,d,desc);
   if cfgsc.SimNb>1 then cfgsc.FindName:=cfgsc.FindName+' '+d; // add date to the name if simulation for more than one date
end;
end;

function Tskychart.DrawEqGrid;
var ra1,de1,ac,dc,dra,dde:double;
    col,n:integer;
    ok:boolean;
    
function DrawRAline(ra,de,dd:double):boolean;
var x1,y1:double;
    n,xx,yy,xxp,yyp: integer;
begin
projection(ra,de,x1,y1,false,cfgsc) ;
WindowXY(x1,y1,xxp,yyp,cfgsc);
n:=0;
repeat
 inc(n);
 de:=de+dd/3;
 projection(ra,de,x1,y1,cfgsc.horizonopaque,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 if (xx>-cfgsc.Xmax)and(xx<2*cfgsc.Xmax)and(yy>-cfgsc.Ymax)and(yy<2*cfgsc.Ymax)
    then Fplot.Plotline(xxp,yyp,xx,yy,col,1);
 xxp:=xx;
 yyp:=yy;
until (xx<-cfgsc.Xmax)or(xx>2*cfgsc.Xmax)or
      (yy<-cfgsc.Ymax)or(yy>2*cfgsc.Ymax)or
      (de>(pid2-2*dd/3))or(de<(-pid2-2*dd/3));
result:=(n>1);
end;
function DrawDEline(ra,de,da:double):boolean;
var x1,y1:double;
    n,xx,yy,xxp,yyp: integer;
begin
projection(ra,de,x1,y1,false,cfgsc) ;
WindowXY(x1,y1,xxp,yyp,cfgsc);
n:=0;
repeat
 inc(n);
 ra:=ra+da/3;
 projection(ra,de,x1,y1,cfgsc.horizonopaque,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 if (xx>-cfgsc.Xmax)and(xx<2*cfgsc.Xmax)and(yy>-cfgsc.Ymax)and(yy<2*cfgsc.Ymax)
    then Fplot.Plotline(xxp,yyp,xx,yy,col,1);
 xxp:=xx;
 yyp:=yy;
until (xx<-cfgsc.Xmax)or(xx>2*cfgsc.Xmax)or
      (yy<-cfgsc.Ymax)or(yy>2*cfgsc.Ymax)or
      (ra>ra1+pi)or(ra<ra1-pi);
result:=(n>1);
end;

begin
result:=false;
if not cfgsc.ShowEqGrid then exit;
col:=Fplot.cfgplot.Color[13];
n:=GetFieldNum(cfgsc.fov/cos(cfgsc.decentre));
dra:=Fcatalog.cfgshr.HourGridSpacing[n];
dde:=Fcatalog.cfgshr.DegreeGridSpacing[cfgsc.FieldNum];
ra1:=deg2rad*trunc(rad2deg*cfgsc.racentre/15/dra)*dra*15;
de1:=deg2rad*trunc(rad2deg*cfgsc.decentre/dde)*dde;
dra:=deg2rad*dra*15;
dde:=deg2rad*dde;
ac:=ra1; dc:=de1;
repeat
  ok:=DrawRAline(ac,dc,dde);
  ok:=DrawRAline(ac,dc,-dde) or ok;
  ac:=ac+dra;
until (not ok)or(ac>ra1+pi+musec);
ac:=ra1; dc:=de1;
repeat
  ok:=DrawRAline(ac,dc,dde);
  ok:=DrawRAline(ac,dc,-dde) or ok;
  ac:=ac-dra;
until (not ok)or(ac<ra1-pi-musec);
ac:=ra1; dc:=de1;
repeat
  ok:=DrawDEline(ac,dc,dra);
  ok:=DrawDEline(ac,dc,-dra) or ok;
  dc:=dc+dde;
until (not ok)or(dc>pid2);
ac:=ra1; dc:=de1;
repeat
  ok:=DrawDEline(ac,dc,dra);
  ok:=DrawDEline(ac,dc,-dra) or ok;
  dc:=dc-dde;
until (not ok)or(dc<-pid2);
result:=true;
end;

function Tskychart.DrawAzGrid;
var a1,h1,ac,hc,dda,ddh:double;
    col,n:integer;
    ok:boolean;
    
function DrawAline(a,h,dd:double):boolean;
var x1,y1:double;
    n,xx,yy,xxp,yyp: integer;
begin
proj2(-a,h,-cfgsc.acentre,cfgsc.hcentre,x1,y1,cfgsc) ;
WindowXY(x1,y1,xxp,yyp,cfgsc);
n:=0;
repeat
 inc(n);
 h:=h+dd/3;
 if cfgsc.horizonopaque and (h<-musec) then break;
 proj2(-a,h,-cfgsc.acentre,cfgsc.hcentre,x1,y1,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 if (xx>-cfgsc.Xmax)and(xx<2*cfgsc.Xmax)and(yy>-cfgsc.Ymax)and(yy<2*cfgsc.Ymax)
    then Fplot.Plotline(xxp,yyp,xx,yy,col,1);
 xxp:=xx;
 yyp:=yy;
until (xx<-cfgsc.Xmax)or(xx>2*cfgsc.Xmax)or
      (yy<-cfgsc.Ymax)or(yy>2*cfgsc.Ymax)or
      (h>(pid2-2*dd/3))or(h<(-pid2-2*dd/3));
result:=(n>1);
end;
function DrawHline(a,h,da:double):boolean;
var x1,y1:double;
    n,xx,yy,xxp,yyp,w: integer;
begin
if h=0 then w:=2 else w:=1;
proj2(-a,h,-cfgsc.acentre,cfgsc.hcentre,x1,y1,cfgsc) ;
WindowXY(x1,y1,xxp,yyp,cfgsc);
n:=0;
repeat
 inc(n);
 a:=a+da/3;
 proj2(-a,h,-cfgsc.acentre,cfgsc.hcentre,x1,y1,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 if (xx>-cfgsc.Xmax)and(xx<2*cfgsc.Xmax)and(yy>-cfgsc.Ymax)and(yy<2*cfgsc.Ymax)
    then Fplot.Plotline(xxp,yyp,xx,yy,col,w);
 xxp:=xx;
 yyp:=yy;
until (xx<-cfgsc.Xmax)or(xx>2*cfgsc.Xmax)or
      (yy<-cfgsc.Ymax)or(yy>2*cfgsc.Ymax)or
      (a>a1+pi)or(a<a1-pi);
result:=(n>1);
end;

begin
result:=false;
if (not cfgsc.ShowAzGrid)or(not(cfgsc.ProjPole=Altaz)) then exit;
col:=Fplot.cfgplot.Color[12];
n:=GetFieldNum(cfgsc.fov/cos(cfgsc.hcentre));
dda:=Fcatalog.cfgshr.DegreeGridSpacing[n];
ddh:=Fcatalog.cfgshr.DegreeGridSpacing[cfgsc.FieldNum];
a1:=deg2rad*trunc(rad2deg*cfgsc.acentre/dda)*dda;
h1:=deg2rad*trunc(rad2deg*cfgsc.hcentre/ddh)*ddh;
dda:=deg2rad*dda;
ddh:=deg2rad*ddh;
ac:=a1; hc:=h1;
repeat
  ok:=DrawAline(ac,hc,ddh);
  ok:=DrawAline(ac,hc,-ddh) or ok;
  ac:=ac+dda;
until (not ok)or(ac>a1+pi);
ac:=a1; hc:=h1;
repeat
  ok:=DrawAline(ac,hc,ddh);
  ok:=DrawAline(ac,hc,-ddh) or ok;
  ac:=ac-dda;
until (not ok)or(ac<a1-pi);
ac:=a1; hc:=h1;
repeat
  if cfgsc.horizonopaque and (hc<-musec) then break;
  ok:=DrawHline(ac,hc,dda);
  ok:=DrawHline(ac,hc,-dda) or ok;
  hc:=hc+ddh;
until (not ok)or(hc>pid2);
ac:=a1; hc:=h1;
repeat
  if cfgsc.horizonopaque and (hc<-musec) then break;
  ok:=DrawHline(ac,hc,dda);
  ok:=DrawHline(ac,hc,-dda) or ok;
  hc:=hc-ddh;
until (not ok)or(hc<-pid2);
result:=true;
end;

Procedure Tskychart.GetLabPos(ra,dec,r:double; w,h: integer; var x,y: integer);
var x1,y1:double;
    xx,yy,rr:integer;
const spacing=10;    
begin
 // no precession, the label position is already for the rigth equinox
 projection(ra,dec,x1,y1,true,cfgsc) ;
 WindowXY(x1,y1,xx,yy,cfgsc);
 rr:=round(r*cfgsc.BxGlb);
 x:=xx;
 y:=yy;
 if (xx>cfgsc.Xmin) and (xx<cfgsc.Xmax) and (yy>cfgsc.Ymin) and (yy<cfgsc.Ymax) then begin
    case cfgsc.LabelOrientation of
    0 : begin                    // to the left
         x:=xx-rr-spacing-w;
         y:=y-(h div 2);
        end;
    1 : begin                    // to the right
         x:=xx+rr+spacing;
         y:=y-(h div 2);
        end;
    end;
 end;
end;

function Tskychart.DrawConstL:boolean;
var
  dm,xx1,yy1,xx2,yy2,ra,de : Double;
  x1,y1,x2,y2,i,color : Integer;
begin
result:=false;
if not cfgsc.ShowConstl then exit;
dm:=minvalue([10*cfgsc.fov,2.5]);
color := Fplot.cfgplot.Color[16];
for i:=0 to catalog.cfgshr.ConstLnum-1 do begin
  ra:=catalog.cfgshr.ConstL[i].ra1;
  de:=catalog.cfgshr.ConstL[i].de1;
  precession(jd2000,cfgsc.JDChart,ra,de);
  projection(ra,de,xx1,yy1,true,cfgsc) ;
  if (abs(xx1)>dm)or(abs(yy1)>dm) then continue;
  ra:=catalog.cfgshr.ConstL[i].ra2;
  de:=catalog.cfgshr.ConstL[i].de2;
  precession(jd2000,cfgsc.JDChart,ra,de);
  projection(ra,de,xx2,yy2,true,cfgsc) ;
  if (abs(xx2)>dm)or(abs(yy2)>dm) then continue;
  if (xx1<199)and(xx2<199) then begin
     WindowXY(xx1,yy1,x1,y1,cfgsc);
     WindowXY(xx2,yy2,x2,y2,cfgsc);
     FPlot.PlotLine(x1,y1,x2,y2,color,1);
  end;
end;
result:=true;
end;


end.
