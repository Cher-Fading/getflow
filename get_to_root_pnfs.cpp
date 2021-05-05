#include <istream>
#include <ostream>

void get_to_root_pnfs(const char *dataType = "",const char *centrality = "PC")
{
    std::ifstream file(Form("%s_%s_pnfs.txt", dataType,centrality));
    std::string line;
    std::ofstream outfile(Form("%s_%s_root_pnfs.txt", dataType,centrality));
    int nl = 0;
    while (std::getline(file, line))
    {
      //cout << line << endl;
        std::stringstream linestream(line);
        std::string item;
        int linePos = -1;
        std::string fileName;
        while (std::getline(linestream, item, '|'))
        {

            	  //std::cout <<  item << " linePos " << linePos << endl;
	  ++linePos;
		 if (linePos!=5) continue;
            if (linePos == 5 && item.find("BNL-OSG2_LOCALGROUPDISK") == std::string::npos) continue;
                std::string::iterator end_pos = std::remove(item.begin(), item.end(), ' ');
                item.erase(end_pos, item.end());
                //cout << end_pos << endl;
                //cout << item << endl;
                int start_pos = item.rfind("/pnfs/");
//cout << item.length() << endl;
                //cout << start_pos << endl;
//cout << item.substr(start_pos,6)<< endl;
                fileName = item.substr(start_pos, item.length() - start_pos);
                //cout << fileName << endl;
//return;
                if (fileName.find(".root") == std::string::npos)
                {
                    cout << fileName << "file missing" << endl;
                    return;
                }
                if (fileName.find("AOD") == std::string::npos)
                {
                    cout << fileName << "file missing" << endl;
                    break;
                }
                //cout << fileName << endl;
                outfile << fileName << endl;
		++nl;

        }

    }
    file.close();
    outfile.close();
    cout << "number of files: " << nl << endl;
}
