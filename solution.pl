% sevde sarikaya
% compiling: yes
% complete: yes

% artist(ArtistName, Genres, AlbumIds).
% album(AlbumId, AlbumName, ArtistNames, TrackIds).
% track(TrackId, TrackName, ArtistNames, AlbumName, [Explicit, Danceability, Energy,
%                                                    Key, Loudness, Mode, Speechiness,
%                                                    Acousticness, Instrumentalness, Liveness,
%                                                    Valence, Tempo, DurationMs, TimeSignature]).







% gets all the track ids of given album list recursively.
getTrackIds([],[]).
getTrackIds([H|Tail],List1):-album(H,_,_,List),getTrackIds(Tail,List3),append(List,List3,List1). 

% gets the names of the tracks from given track ids list recursively.
getTrackNames([], []).
getTrackNames([H|Tail],List):-track(H,Nm,_,_,_),getTrackNames(Tail,List2), List=[Nm|List2].

% getArtistTracks(+ArtistName, -TrackIds, -TrackNames) 5 points
% gets all the tracks' names and ids of an artist by using getTrackIds and getTrackNames.
getArtistTracks(X,TrackIds,TrackNames):- artist(X,_,List1),getTrackIds(List1,TrackIds), getTrackNames(TrackIds,TrackNames).


% sums the features of the given tracks list recursively. (only the sum of important ones)
getTracksFeatures([],0,0,0,0,0,0,0,0).
getTracksFeatures([H|T],A,B,C,D,E,F,G,J):- track(H,_,_,_,[_,A1,B1,_,_,C1,D1,E1,F1,G1,H1,_,_,_]),getTracksFeatures(T,A2,B2,C2,D2,E2,F2,G2,H2),
A is A1+A2, B is B1+B2, C is C1+C2, D is D1+D2, E is E1+E2, F is F1 + F2, G is G1+G2, J is H1+H2.

% calculates the average of the features.
avg( [],_,[]).
avg([H|Tail],N, Avg ):- Avg1 is (H/N),  avg(Tail,N,Avg2), Avg = [Avg1|Avg2].

% gets the tracks of an album and by using getTracksFeatures and avg, calculates the features of an album.
% albumFeatures(+AlbumId, -AlbumFeatures) 5 points
albumFeatures(AlbumId,AlbumFeatures):-getTrackIds([AlbumId],Ids),getTracksFeatures(Ids,A,B,C,D,E,F,G,J), length(Ids,N), avg([A,B,C,D,E,F,G,J],N,AlbumFeatures).


% gets the albumlist of an artist and finds the artist's tracks. Then, bu usign getTracksFeatures and avg calculates the features of an artist.
% artistFeatures(+ArtistName, -ArtistFeatures) 5 points
artistFeatures(ArtistName, ArtistFeatures):-artist(ArtistName,_,AlbumList),
getTrackIds(AlbumList,Ids),
getTracksFeatures(Ids,A,B,C,D,E,F,G,J),
length(Ids,N),
avg([A,B,C,D,E,F,G,J],N,ArtistFeatures).


% trackDistance(+TrackId1, +TrackId2, -Score) 5 points

% by using getTracksFeatures calculates the distance of two tracks.
trackDistance(TrackId1, TrackId2, Score):- getTracksFeatures([TrackId1],A,B,C,D,E,F,G,J), getTracksFeatures([TrackId2],A1,B1,C1,D1,E1,F1,G1,J1), Score is sqrt((A-A1)**2+(B-B1)**2+(C-C1)**2+(D-D1)**2+(E-E1)**2+(F-F1)**2+(G-G1)**2+(J-J1)**2).



% albumDistance(+AlbumId1, +AlbumId2, -Score) 5 points

% by using albumFeatures calculates the distance of two tracks.
albumDistance(AlbumId1, AlbumId2, Score):- albumFeatures(AlbumId1,[A,B,C,D,E,F,G,J]),albumFeatures(AlbumId2,[A1,B1,C1,D1,E1,F1,G1,J1]), Score is sqrt((A-A1)**2+(B-B1)**2+(C-C1)**2+(D-D1)**2+(E-E1)**2+(F-F1)**2+(G-G1)**2+(J-J1)**2).



% artistDistance(+ArtistName1, +ArtistName2, -Score) 5 points

% by using artistFeatures calculates the distance of two tracks.
artistDistance(ArtistName1, ArtistName2, Score):- artistFeatures(ArtistName1, [A,B,C,D,E,F,G,J]), artistFeatures(ArtistName2, [A1,B1,C1,D1,E1,F1,G1,J1]), Score is sqrt((A-A1)**2+(B-B1)**2+(C-C1)**2+(D-D1)**2+(E-E1)**2+(F-F1)**2+(G-G1)**2+(J-J1)**2).


% calculates the distances to the given track of all the tracks in the list till the list is empty and makes pair with distance and id. 
distance([],_,[]).
distance([H|Tail],Id,List1):- trackDistance(Id,H,Dist), distance(Tail,Id,List2), append([Dist],[H],List), List1=[List|List2].


% gets the N elements of the list.
getFirst(_,0,[]).
getFirst([[_|Tail]|T],N,List):- N>0,N1 is N-1, getFirst(T,N1,List1), append(Tail,List1,List).


% sorts the tracks by using distance, sort and getFirst predicates and gets the first 30 tracks.
sortEm(TrackId,Sorted):- findall(X,track(X,_,_,_,_),Ids), distance(Ids,TrackId,Distances), sort(Distances,End),getFirst(End,31,Sorted).



% findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames) 10 points

% uses sortEm and getTrackNames. Gets 30 tracks which are the most similar with the given track.
findMostSimilarTracks(TrackId, SimilarIds, SimilarNames):- sortEm(TrackId,[_|SimilarIds]), getTrackNames(SimilarIds,SimilarNames).


% gets the album names of an artist.
getAlbumNames( [],[]).
getAlbumNames([H|Tail],List):- album(H,Name,_,_),getAlbumNames(Tail,List1), List=[Name|List1].

% calculates the distances to the given id of albums and pair the distance and the album id.
distanceAlbum([],_,[]).
distanceAlbum([H|Tail],Id,List1):- albumDistance(Id,H,Dist), distanceAlbum(Tail,Id,List2), append([Dist],[H],List), List1=[List|List2].

% sorts the albums by using distanceAlbum, sort and getFirst. Returns the first 30 albums which are the most similar to the given album id.
sortEmAlbum(AlbumId,Sorted):- findall(X,album(X,_,_,_),Ids), distanceAlbum(Ids,AlbumId,Distances), sort(Distances,End),getFirst(End,31,Sorted).




% findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames) 10 points

% to find the most similar first 30 albums uses sortEmAlbum and gelAlbumNames.
findMostSimilarAlbums(AlbumId, SimilarIds, SimilarNames):- sortEmAlbum(AlbumId,[_|SimilarIds]), getAlbumNames(SimilarIds,SimilarNames).


% calculates the distances to the given artist of the other artists by using artistDistance predicate and pair the distance and artist.
distanceArtist([],_,[]).
distanceArtist([H|Tail],Id,List1):- artistDistance(Id,H,Dist), distanceArtist(Tail,Id,List2), append([Dist],[H],List), List1=[List|List2].

% sorts the artist by using distanceArtist, sort and getFirst, returns the first 30 artists which are similar to the given artist.
sortEmArtist(ArtistName,Sorted):- findall(X,artist(X,_,_),Ids), distanceArtist(Ids,ArtistName,Distances), sort(Distances,End),getFirst(End,31,Sorted).




% findMostSimilarArtists(+ArtistName, -SimilarArtists) 10 points

% finds most similar 30 artists by using sortEmArtist.
findMostSimilarArtists(ArtistName, SimilarArtists):- sortEmArtist(ArtistName,[_|SimilarArtists]).


% filters the explicit tracks recursively.
filterE( [],[]).
filterE([H|T],Filter):- track(H,_,_,_,[A|_]),filterE(T,Filter2),(A<1 ->Filter= [H|Filter2]; Filter= Filter2).



% filterExplicitTracks(+TrackList, -FilteredTracks) 5 points

% uses only filterE to filter the explicit tracks.
filterExplicitTracks(TrackList, FilteredTracks):- filterE(TrackList,FilteredTracks).


% gets the genres of artists and unites them(no duplicates)
getGenres( [],[]).
getGenres([H|T], Genres):- artist(H,Genres2,_), getGenres(T,Genres3), union(Genres2,Genres3,Genres).




% getTrackGenre(+TrackId, -Genres) 5 points
% gets the genres of a track by searching the genres of artists, uses only getGenres predicate.
getTrackGenre(TrackId, Genres):- track(TrackId,_,Artists,_,_),getGenres(Artists,Genres).


% checks if any element in the list is included in the given Genre. If it's included then returns fail. 
checkDis( _,[]).
checkDis(Genre,[H|T]):- (sub_string(Genre,_,_,_,H) -> fail; checkDis(Genre,T)).
% checks if the genres of an artist includes any disliked genre by using checkDis predicate. If it does, return fail.
checkArtist([],_).
checkArtist([H|T],Disliked):- ( checkDis(H,Disliked)-> (checkArtist(T,Disliked); fail)).

% filters the tracks which has disliked genres by using getTrackGenre,checkArtist  predicates.
filterDislike( [],_,[]).
filterDislike([[H|Tail]|T],Disliked,List):-  atomics_to_string(Tail,Id),getTrackGenre(Id,Genres), filterDislike(T,Disliked,List2),
(checkArtist(Genres,Disliked)-> append([[H|Tail]],List2,List); List=List2).

% calculates the distance of a track to the given features by getting its features.
featureDistances([A,B,C,D,E,F,G,J], TrackId, Score):-  track(TrackId,_,_,_,[_,A1,B1,_,_,C1,D1,E1,F1,G1,J1,_,_,_]), Score is sqrt((A-A1)**2+(B-B1)**2+(C-C1)**2+(D-D1)**2+(E-E1)**2+(F-F1)**2+(G-G1)**2+(J-J1)**2).

% calculates all the tracks' distances to the given features by using featureDistances predicates and pairs them.
fdistance([],_,[]).
fdistance([H|Tail],[A,B,C,D,E,F,G,J],List1):- featureDistances([A,B,C,D,E,F,G,J],H,Dist), fdistance(Tail,[A,B,C,D,E,F,G,J],List2), append([Dist],[H],List), List1=[List|List2].




% gets the first N elements and the second element of the pair from given list(which has pair form).
getFirstD(_,0,[]).
getFirstD([[_|Tail]|T],N,List):- N>0,N1 is N-1,getFirstD(T,N1,List1),atomics_to_string(Tail,Id),List = [Id|List1].

% gets the distances and the first N elements from the given list(which has pair form).
getFirstD2(_,0,[]).
getFirstD2([[H|_]|T],N,List):- N>0,N1 is N-1,getFirstD2(T,N1,List1),List = [H|List1].

% gets the tracks which has liked genres from a list by using getTrackGenre, checkArists predicates.
filterLike([],_,[]).
filterLike([[H|Tail]|T],Liked,List):- atomics_to_string(Tail,Id),getTrackGenre(Id,Genres), filterLike(T,Liked,List2),
(checkArtist(Genres,Liked)->  List=List2; List= [[H|Tail]|List2]).

% gets the first element of the pairs which is the distance of the track.
getDistance( [],[]).
getDistance([[H|_]|T], List):- getDistance(T,List2), List = [H|List2].

% gets the owners of the tracks recursively.
getArtistName( [],[]).
getArtistName([H|T],Artists):- track(H,_,A,_,_), getArtistName(T,Artists2), Artists= [A|Artists2].

% calculates the distances (fdistance) and sorts. Then filters the songs which have disliked genres and gets the tracks which have liked genres. Then gets the first 30 tracks with their distances.
sortEmAll(Liked,Disliked,Features,Sorted,Distance):- findall(X,track(X,_,_,_,_),Ids), fdistance(Ids,Features,Distances), sort(Distances,End),filterDislike(End,Disliked,Filtered), filterLike(Filtered,Liked,List), getFirstD(List,30,Sorted),getFirstD2(List,30,Distance).

% discovers a playlist by using the given LikedGenres, DislikedGenres and Features. Uses sortEmAll, getTrackNames,getArtistName predicates and writes the outputs to the given fileName.


% discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist) 30 points
discoverPlaylist(LikedGenres, DislikedGenres, Features, FileName,Playlist):- 
    open(FileName,write, Stream),
    sortEmAll(LikedGenres,DislikedGenres,Features,Playlist,Distance), writeln(Stream,Playlist),
	getTrackNames(Playlist,Names), writeln(Stream,Names),nl,
	getArtistName(Playlist,Artists), writeln(Stream,Artists), writeln(Stream,Distance),
	
    close(Stream).











