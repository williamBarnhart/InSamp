tmp    = toc;
s    = s+1;
time = tmp*(alli-s);
if (time>3600)
  hours=floor(time/3600);
  minutes=round((time-3600*hours)/60);
  string=[num2str(hours) ' hours ' num2str(minutes) ' minutes left'];
  waitbar(s/alli,h,[num2str(hours) ' hours ' num2str(minutes) ' minutes left']);
elseif (time>60)
  minutes=floor(time/60);
  seconds=round(time-60*minutes);
  string=[num2str(minutes) ' minutes ' num2str(seconds) ' sec left'];
  waitbar(s/alli,h,[num2str(minutes) ' minutes ' num2str(seconds) ' sec left']);
else
  string=[num2str(round(time)) ' seconds left'];
  waitbar(s/alli,h,[num2str(round(time)) ' seconds left']);
end

set(h,'name',string)
%set(h,'name',[num2str(s) '/' num2str(alli)])
clear minutes hours seconds time
