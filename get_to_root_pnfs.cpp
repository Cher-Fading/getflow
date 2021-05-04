#include <istream>
#include <ostream>

void get_to_root_pnfs(const char *dataType = "")
{
    std::ifstream file(Form("../GetStuff/%s_pnfs.txt", dataType));
    std::string line;
    std::ofstream outfile(Form("../GetStuff/%s_root_pnfs.txt", dataType));
    int nl = 0;
    while (std::getline(file, line))
    {
        std::stringstream linestream(line);
        std::string item;
        int linePos = 0;
        std::string fileName;
        while (std::getline(linestream, item, '|'))
        {

            //	  std::cout <<  item << " linePos " << linePos << endl;
            if (linePos == 5)
            {
                if (item.find("REPLICA") != std::string::npos)
                    continue;
                std::string::iterator end_pos = std::remove(item.begin(), item.end(), ' ');
                item.erase(end_pos, item.end());
                //cout << end_pos << endl;
                //cout << item << endl;
                int start_pos = item.find_last_of("=");
                //cout << start_pos << endl;
                fileName = item.substr(start_pos + 1, item.length() - start_pos - 1);
                //cout << fileName << endl;

                if (fileName.find(".root") == std::string::npos)
                {
                    cout << fileName << "file missing" << endl;
                    return;
                }
                if (fileName.find("user.xiaoning") == std::string::npos)
                {
                    cout << fileName << "file missing" << endl;
                    break;
                }
                //cout << fileName << endl;
                outfile << fileName << endl;
            }
            ++linePos;
        }
	++nl;
    }
    file.close();
    outfile.close();
    cout << "number of files: " << nl << endl;
}
