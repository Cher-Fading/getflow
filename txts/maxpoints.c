
//1,-2,3,2,1;1,2,4,-8,2;2,1,6,4,3;3,-7,1,0,-4;4,3,2,2,1
//1,2,3,4,5;1,2,3,4,5;1,2,3,4,5;1,2,3,4,5;1,2,3,4,5
//1,-2,3;-4,5,-6;7,-8,-9
//1,2,3;4,5,6;7,8,9
bool priority(string a, string b){//-1 b prioritize over a, 1 a prioritize over b, 0, equal
//return true if a is more prioritized than b, they should have same length
int steps=a.size();
for (int i=0; i < a;i++){
                        //case 1, do change
                        if ((a[i] =='u' || a[i] =='d')&& (b[i] =='l' || b[i] =='r')){
                                return false;
                            }
  
                        //case 2, definitely won't change
                        if ((a[i] =='l' || a[i] =='r')&& (b[i] =='u' || b[i] =='d')){
                            return true;
                        }
                    }
return false;
}
string maxpoints(string inputf="test.txt")
{
    vector<vector<int>> grid;
    ifstream infile(inputf.c_str());
string s;
	if (infile){
getline(infile,s);
}
stringstream ss(s);
//cout << s<< endl;
string sa;
    while (getline(ss,sa,';')){
        stringstream a(sa);
        string sb;
        vector<int> single;
        while (getline(a,sb,',')){
            single.push_back(stoi(sb));
        }
        grid.push_back(single);
    }
//order:left top right top left bottom right bottom
    vector<vector<int>> dire = {{1, 1}, {1, -1}, {-1, -1}, {-1, 1}};
    vector<vector<string>> direp = {{"d", "r"}, {"d", "l"}, {"u", "l"}, {"u", "r"}};

    int n = grid.size();
cout << "n:"<< n << endl;
for (int i=0; i < n; i++){
for (int j=0; j < n; j++){
//cout << grid[i][j] << ",";
}
//cout << endl;
}
//return "";
    if (n==1) return "";
    int res = INT_MIN;
    string pathres = "";
    int steps=n-1;
    // horizontal first
    vector<vector<int>> st = {{0, 0}, {0, n-1}, {n-1, n-1}, {n-1, 0}};
    // left top right top left bottom right bottom
    for (int v = 0; v <= 1; v++)
    {
        for (int h = 0; h <= 1; h++)
        {
cout << "v:" <<v << ";h:" << h << endl; 
            int stx=st[v*2+h][0];//start index x
            int sty=st[v*2+h][1];//start index y
            vector<string> path((n+1)/2,"");
            vector<int> dp((n+1)/2, INT_MIN);
cout << "v" << v << ";h" << h << endl;
cout << "stx:" << stx << ";sty:" << sty << endl;
            dp[0] = grid[stx][sty];
            //initialize edges (c=sty)
int r=stx;
            for (int i=1; i <(n+1)/2; i++){

		r+=dire[v*2+h][0];
cout << "r" << r << endl;
dp[i]=dp[i-1]+grid[r][sty];
path[i]=path[i-1]+direp[v*2+h][0];
cout << path[i] << endl;
}
            
cout << "finished col 0 initialization" << endl;
            int c=sty;
for (int j=1; j<(n+1)/2; j++){
c+=dire[v*2+h][1];
dp[0]+=grid[stx][c];
path[0]+=direp[v*2+h][1];
                r=stx;
  
                for (int i=1; i < (n+1)/2; i++){
                    r+=dire[v*2+h][0];
cout << "rc:" << r << c << ":dp[i-1]:" << dp[i-1] << "dp[i]:" <<dp[i] <<endl;
                    if (dp[i-1]>dp[i]){//move vertically
                        path[i]=path[i-1]+direp[v*2+h][0];
dp[i]=dp[i-1];
                    }else if (dp[i-1]<dp[i]){//move horizontally
                        path[i]+=direp[v*2+h][1];
                    }else if (dp[i-1]==dp[i]){
if (priority(path[i-1],path[i])){//if greater, move vertically, if equal or less, move horizontally
path[i]=path[i-1]+direp[v*2+h][0];
}
else{path[i]+=direp[v*2+h][1];}
}
cout << path[i] << ";" << dp[i] << endl;
                    dp[i]+=grid[r][c];
                }
            }
cout << "sum:" << dp[(n-1)/2]<< endl;
cout << "path:" << path[(n-1)/2] << endl;
                if (dp[(n-1)/2]>res){
                    res=dp[(n-1)/2];
                    pathres=path[(n-1)/2];
                    continue;
                }
                if (dp[(n-1)/2]==res){
                    if (priority(path[(n-1)/2],pathres)){pathres=path[(n-1)/2];}
                }
        }
}

    return pathres;
}
